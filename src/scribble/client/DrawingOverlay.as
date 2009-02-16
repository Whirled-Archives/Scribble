package scribble.client {

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import com.threerings.util.ValueEvent;

/** Fires local drawing events and displays local painting. */
public class DrawingOverlay extends Sprite
{
    public static const BRUSH_DOWN :String = "BrushDown";
    public static const BRUSH_UP :String = "BrushUp";
    public static const BRUSH_DRAG :String = "BrushDrag";

    public function DrawingOverlay (width :int, height :int)
    {
        _width = width;
        _height = height;

        // Set up brush event dispatching
        addEventListener(MouseEvent.MOUSE_DOWN, function (event :MouseEvent) :void {
            if (!_brushDown) {
                _brushDown = true;
                dispatchBrush(BRUSH_DOWN, event);
            }
        });
        addEventListener(MouseEvent.MOUSE_UP, function (event :MouseEvent) :void {
            if (_brushDown) {
                _brushDown = false;
                dispatchBrush(BRUSH_UP, event);
            }
        });
        addEventListener(MouseEvent.MOUSE_MOVE, function (event :MouseEvent) :void {
            if (_brushDown) {
                dispatchBrush(BRUSH_DRAG, event);
            }
        });
        addEventListener(MouseEvent.ROLL_OVER, function (event :MouseEvent) :void {
            if (event.buttonDown && !_brushDown) {
                _brushDown = true;
                dispatchBrush(BRUSH_DOWN, event);
            }
        });
        addEventListener(MouseEvent.ROLL_OUT, function (event :MouseEvent) :void {
            if (event.buttonDown || _brushDown) {
                _brushDown = false;
                if (event.relatedObject != null ||
                    ("isRelatedObjectInaccessible" in event && event["isRelatedObjectInaccessible"])) {
                    dispatchBrush(BRUSH_DRAG, event);
                }
                dispatchBrush(BRUSH_UP, event);
            }
        });

        // Now listen to some of our own brush events to show local feedback
        addEventListener(BRUSH_DOWN, function (event :ValueEvent) :void {
            var point :Point = event.value as Point;
            push();
            _localShapes[0].graphics.moveTo(point.x, point.y);
        });
        addEventListener(BRUSH_DRAG, function (event :ValueEvent) :void {
            var point :Point = event.value as Point;
            GraphicsUtil.setupBrush(_localShapes[0], _brushId);
            _localShapes[0].graphics.lineTo(point.x, point.y);
        });

        clear();

        var masker :Shape = new Shape();
        masker.graphics.beginFill(0);
        masker.graphics.drawRect(0, 0, _width, _height);
        masker.graphics.endFill();
        addChild(masker);
        this.mask = masker;

        this.mouseChildren = false;
    }

    public function clear () :void
    {
        // Fill with click-eating transparency
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, _width, _height);
        graphics.endFill();

        for each (var shape :Shape in _localShapes) {
            removeChild(shape);
        }
        _localShapes = [];
    }

    public function push () :void
    {
        var shape :Shape = new Shape();

        _localShapes.unshift(shape);
        addChild(shape);
    }

    public function pop () :void
    {
        if (_localShapes.length > 0) {
            removeChild(Shape(_localShapes.pop()));
        }
    }

    public function setBrush (brushId :int) :void
    {
        _brushId = brushId;
    }

    // Helper
    protected function dispatchBrush (eventName :String, mouse :MouseEvent) :void
    {
        dispatchEvent(new ValueEvent(eventName, new Point(mouse.localX, mouse.localY)));
    }

    protected var _width :int;
    protected var _height :int;

    protected var _localShapes :Array = []; // of Shape
    protected var _brushDown :Boolean;

    protected var _brushId :int;
}

}
