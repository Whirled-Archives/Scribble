package scribble.client {

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Mouse;

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
            _cursor.x = event.localX;
            _cursor.y = event.localY;
        });
        addEventListener(MouseEvent.ROLL_OVER, function (event :MouseEvent) :void {
            if (event.buttonDown && !_brushDown) {
                _brushDown = true;
                dispatchBrush(BRUSH_DOWN, event);
            }
            addChild(_cursor);
            Mouse.hide();
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
            removeChild(_cursor);
            Mouse.show();
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

        addChild(_paints);

        _cursor.addChild(new CURSOR());

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
            _paints.removeChild(shape);
        }
        _localShapes = [];
    }

    public function push () :void
    {
        var shape :Shape = new Shape();

        _localShapes.unshift(shape);
        _paints.addChild(shape);
    }

    public function pop () :void
    {
        if (_localShapes.length > 0) {
            _paints.removeChild(Shape(_localShapes.pop()));
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

    [Embed(source="../../../res/cursor.png")]
    protected static const CURSOR :Class;
    protected var _cursor :Sprite = new Sprite();

    protected var _width :int;
    protected var _height :int;

    /** Contains all the local shapes, to ensure the cursor is always on top. */
    protected var _paints :Sprite = new Sprite();

    protected var _localShapes :Array = []; // of Shape
    protected var _brushDown :Boolean;

    protected var _brushId :int;
}

}
