package scribble.client {

import flash.display.InteractiveObject;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.utils.setTimeout;

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

    public static function getColor (brushId :int) :int
    {
        var r :int = (brushId>>4) & 3;
        var g :int = (brushId>>2) & 3;
        var b :int = brushId & 3;
        return r*0x550000 + g*0x005500 + b*0x000055;
    }

    public static function getWidth (brushId :int) :int
    {
        var width :int = (brushId>>6) & 3;
        return (brushId < 0) ? 3-width : width;
    }

    public static function setupBrush (shape :Shape, brushId :int) :void
    {
        var width :int = Math.pow(2, getWidth(brushId)+1);
        if (brushId >= 0) {
            shape.graphics.lineStyle(width, getColor(brushId));
        } else {
            shape.blendMode = BlendMode.ERASE;
            // Two's complement
            shape.graphics.lineStyle(2*width, 0xffffff);
        }

        // Optimization
        shape.cacheAsBitmap = true;
    }

    /** Like GTween.reverse(), but always ensures playback. */
    public static function flip (tween :GTween) :void
    {
        tween.reverse();
        if (tween.state == GTween.END) {
            tween.play();
        }
    }

    public static function throttleClicks (source :InteractiveObject, timeout :int = 2000) :void
    {
        source.addEventListener(MouseEvent.CLICK, function (... _) :void {
            source.mouseEnabled = false;
            setTimeout(function () :void {
                source.mouseEnabled = true;
            }, timeout);
        });
    }
}

}
