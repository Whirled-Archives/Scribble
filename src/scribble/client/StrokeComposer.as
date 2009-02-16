package scribble.client {

import flash.events.EventDispatcher;
import flash.events.Event;
import flash.geom.Point;

import com.threerings.util.ValueEvent;

import scribble.data.Stroke;

public class StrokeComposer extends EventDispatcher
{
    /** A valid stroke has finished being composed and is ready to be sent. */
    public static const STROKE_COMPOSED :String = "StrokeComposed";

    /** A stroke was invalid after composing. */
    public static const STROKE_REJECTED :String = "StrokeRejected";

    public static const TOLERANCE :int = 2; // TODO: Tweak

    public function StrokeComposer (drawing :DrawingOverlay, picker :BrushPicker)
    {
        drawing.addEventListener(DrawingOverlay.BRUSH_DOWN, onBrushDown);
        drawing.addEventListener(DrawingOverlay.BRUSH_UP, onBrushUp);
        drawing.addEventListener(DrawingOverlay.BRUSH_DRAG, onBrushDrag);

        reset();
    }

    protected function onBrushDown (event :ValueEvent) :void
    {
        _stroke.isBeginning = true;
        addPoint(event.value as Point);
    }

    protected function onBrushUp (event :ValueEvent) :void
    {
        _stroke.isEnding = true;
        process();
    }

    protected function onBrushDrag (event :ValueEvent) :void
    {
        addPoint(event.value as Point);
    }

    protected function addPoint (point :Point) :void
    {
        _stroke.points.push(point);

        if (_stroke.points.length > 100) {
            process();
        }
    }

    /** Compresses the Stroke, sends the event and resets. */
    protected function process () :void
    {
        _stroke.brush = _brushId;

        // Don't do anything with "dots"
        if (_stroke.isBeginning && _stroke.points.length < 2) {
            dispatchEvent(new Event(STROKE_REJECTED));

        } else {
            simplify(0, _stroke.points.length-1);

            if (!_stroke.isBeginning) {
                delete _stroke.points[0];
            }
            
            // Convert to non-sparse array
            var denseArray :Array = [];
            for each (var point :Point in _stroke.points) {
                denseArray.push(point);
            }
            _stroke.points = denseArray;

            dispatchEvent(new ValueEvent(STROKE_COMPOSED, _stroke));
        }

        reset();
    }

    protected function simplify (from :int, to :int) :void
    {
        if (to - from < 2) {
            return;
        }

        var a :Point = Point(_stroke.points[from]);
        var b :Point = Point(_stroke.points[to]);
        var delta :Point = a.subtract(b);

        var distance :Number = Point.distance(a, b);

        // Used to keep track of the most significant point
        var maxIndex :int = 0;
        var maxDistance :int = 0;

        for (var ii :int = from+1; ii<to; ++ii) {
            var p :Point = Point(_stroke.points[ii]);

            // The distance from this point to the line formed by the end points
            var d :Number = Math.abs((a.y - p.y)*delta.x - (a.x - p.x)*delta.y) / distance;

            if (d > maxDistance) {
                maxIndex = ii;
                maxDistance = d;
            }
        }

        if (maxDistance > TOLERANCE) {
            // The point at maxIndex is definitely a keeper.
            // Now simplify everything before and after that point.
            simplify(from, maxIndex);
            simplify(maxIndex, to);
        } else {
            // Throw out every point in this sequence
            for (ii = from+1; ii<to; ++ii) {
                delete _stroke.points[ii];
            }
        }
    }

    public function reset () :void
    {
        _stroke = new Stroke();
    }

    public function setBrush (brushId :int) :void
    {
        _brushId = brushId;
    }

    protected var _stroke :Stroke;
    protected var _brushId :int;
}

}
