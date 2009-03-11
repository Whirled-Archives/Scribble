package scribble.client {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;

import com.gskinner.motion.GTween;

import scribble.data.Codes;

public class GraphicsUtil
{
    public static function stepBezier (
        graphics :Graphics, curve :BezierCurve, u :Number) :void
    {
        var u2 :Number = u*u;
        var u3 :Number = u2*u;
     
        graphics.lineTo(
            u3 * (curve.to.x + 3*(curve.control1.x - curve.control2.x) - curve.from.x) +
                3*u2 * (curve.from.x - 2*curve.control1.x + curve.control2.x) +
                3*u * (curve.control1.x-curve.from.x) + curve.from.x,
            u3 * (curve.to.y + 3*(curve.control1.y - curve.control2.y) - curve.from.y) +
                3*u2 * (curve.from.y - 2*curve.control1.y + curve.control2.y) +
                3*u * (curve.control1.y - curve.from.y) + curve.from.y);
    }

    public static function drawBezier (
        graphics :Graphics, curve :BezierCurve) :void
    {
        graphics.moveTo(curve.from.x, curve.from.y);

        for (var u :Number = 0; u <= 1; u += 1/100) {
            stepBezier(graphics, curve, u);
        }
    }

    public static function setupBrush (shape :Shape, brushId :int) :void
    {
        if (brushId > 0) {
            shape.graphics.lineStyle(4, Codes.BRUSH_COLORS[brushId]);
        } else {
            shape.blendMode = BlendMode.ERASE;
            shape.graphics.lineStyle(24, 0xffffff);
        }
    }

    /** Like GTween.reverse(), but always ensures playback. */
    public static function flip (tween :GTween) :void
    {
        tween.reverse();
        if (tween.state == GTween.END) {
            tween.play();
        }
    }
}

}
