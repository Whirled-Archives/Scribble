package scribble.client {

import flash.display.Graphics;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;

import com.gskinner.motion.GTween;

public class BezierAnimation extends EventDispatcher
{
    // Because reusing Event.COMPLETE is evil
    public static const STROKE_COMPLETE :String = "StrokeComplete";

    public function BezierAnimation (graphics :Graphics, curves :Array)
    {
        _graphics = graphics;

        for each (var curve :BezierCurve in curves) {
            add(curve);
        }

        // When done drawing all the curves in the stroke, dispatch an event
        var lastTween :GTween = _tweens[_tweens.length-1];
        lastTween.addEventListener(Event.COMPLETE, function (... _) :void {
            dispatchEvent(new Event(STROKE_COMPLETE));
            //_graphics.lineTo(to.x, to.y); -- Nope, this causes a glitch
        });
    }

    protected function add (curve :BezierCurve) :void
    {
        var tween :GTween = new GTween(null, 0.05, null, { autoPlay: false });

        // On tick, inch along the curve
        tween.addEventListener(Event.CHANGE, function (... _) :void {
            GraphicsUtil.stepBezier(_graphics, curve, tween.position/tween.duration);
        });

        if (_tweens.length > 0) {
            _tweens[_tweens.length-1].nextTween = tween;
        }
        _tweens.push(tween);
    }

    public function play () :void
    {
        if (_tweens.length > 0) {
            _tweens[0].play();
        }
    }

    protected var _graphics :Graphics;
    protected var _tweens :Array = []; // of GTween
}

}
