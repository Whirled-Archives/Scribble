package scribble.client {

import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Point;

import scribble.data.Stroke;

/** Draws and animates smooth strokes as they come in from the server. */
public class StrokeContainer extends Sprite
{
    public static const SMOOTHNESS :Number = 1;

    public function StrokeContainer (width :int, height :int)
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0);
        masker.graphics.drawRect(0, 0, width, height);
        masker.graphics.endFill();
        addChild(masker);
        this.mask = masker;
    }

    public function addStroke (
        stroke :Stroke, strokeId :int, artistId :int, animate :Boolean = true) :void
    {
        var points :Array = stroke.isEnding ?
            stroke.points.concat(stroke.points[stroke.points.length-1]) : stroke.points;

        var p0 :Point;
        var p1 :Point;
        var p2 :Point;
        var p3 :Point;

        var ii :int = 0;
        if (artistId in _continuations) {
            var cont :ContinuationInfo = _continuations[artistId];
            p0 = cont.p0;
            p1 = cont.p1;
            p2 = cont.p2;
        } else {
            p0 = points[ii++];
            p1 = p0;
            p2 = points[ii++]; // TODO: Never send dots
        }

        if (p0 == null || p1 == null || p2 == null || points[ii] == null) {
            Game.log.warning("Wacky Stroke/ContinuationInfo detected. Voodoo programming says: Bail!");
            return;
        }

        var layer :Shape = new Shape();
        layer.graphics.moveTo(p1.x, p1.y);
        GraphicsUtil.setupBrush(layer, stroke.brush);

        var curves :Array = []; // of BezierCurve

        while (ii < points.length) {
            p3 = points[ii++];

            // Midpoints
            var xc1 :Number = (p0.x + p1.x)/2;
            var yc1 :Number = (p0.y + p1.y)/2;
            var xc2 :Number = (p1.x + p2.x)/2;
            var yc2 :Number = (p1.y + p2.y)/2;
            var xc3 :Number = (p2.x + p3.x)/2;
            var yc3 :Number = (p2.y + p3.y)/2;

            // Distances
            var len01 :Number = Point.distance(p0, p1);
            var len02 :Number = Point.distance(p0, p2);
            var len12 :Number = Point.distance(p1, p2);
            var len13 :Number = Point.distance(p1, p3);
            var len23 :Number = Point.distance(p2, p3);

            var k1 :Number = len01/(len01 + len12);
            var k2 :Number = len12/(len12 + len23);

            var xm1 :Number = xc1 + (xc2 - xc1)*k1;
            var ym1 :Number = yc1 + (yc2 - yc1)*k1;
            var xm2 :Number = xc2 + (xc3 - xc2)*k2;
            var ym2 :Number = yc2 + (yc3 - yc2)*k2;

            // Get the relative area (Hero's theorem)
            var s1 :Number = (len01+len12+len02)/2;
            var s2 :Number= (len12+len23+len13)/2;
            var area1 :Number = s1*(s1-len01)*(s1-len12)*(s1-len02);
            var area2 :Number = s2*(s2-len12)*(s2-len23)*(s2-len13);

            var soften :Number = 500000/(area1 + area2)*SMOOTHNESS;

            // Clamp the soften value to acceptable levels
            soften = Math.max(SMOOTHNESS/10, Math.min(soften, SMOOTHNESS));

            var ctrl1_x :Number = xm1 + (xc2 - xm1) * soften + p1.x - xm1;
            var ctrl1_y :Number = ym1 + (yc2 - ym1) * soften + p1.y - ym1;
            var ctrl2_x :Number = xm2 + (xc2 - xm2) * soften + p2.x - xm2;
            var ctrl2_y :Number = ym2 + (yc2 - ym2) * soften + p2.y - ym2;

            var control1 :Point = new Point(ctrl1_x, ctrl1_y);
            var control2 :Point = new Point(ctrl2_x, ctrl2_y);

            curves.push(new BezierCurve(p1, control1, control2, p2));

            // Shift the system along one point
            p0 = p1;
            p1 = p2;
            p2 = p3;
        }

        if (stroke.isEnding) {
            if (artistId in _continuations) {
                delete _continuations[artistId];
            }
        } else {
            _continuations[artistId] = new ContinuationInfo(p0, p1, p2);
        }

        if (animate) {
            var animation :BezierAnimation = new BezierAnimation(layer.graphics, curves);
            var queue :Array;

            if (artistId in _animations) {
                queue = _animations[artistId];
            } else {
                queue = [];
                _animations[artistId] = queue;

                animation.play(); // Start immediately
            }
            queue.push(animation);
            animation.addEventListener(BezierAnimation.STROKE_COMPLETE, function (... _) :void {
                queue.shift();
                if (queue.length == 0) {
                    delete _animations[artistId];
                } else {
                    queue[0].play();
                }
            });

        } else {
            // No fancy animation, just draw them all now
            for each (var curve :BezierCurve in curves) {
                GraphicsUtil.drawBezier(layer.graphics, curve);
            }
        }

        removeStroke(strokeId);
        _layers[strokeId] = layer;

        if (strokeId > this.numChildren) {
            addChild(layer);
        } else {
            addChildAt(layer, strokeId);
        }
    }

//    protected function drawCubicBezier (
//        graphics :Graphics, from :Point, control1 :Point, control2 :Point, to :Point) :void
//    {
//        graphics.moveTo(from.x, from.y);
//
//        // store values where to lineTo
//        var posx :Number;
//        var posy :Number;
//
//        //loop through 100 steps of the curve
//        for (var u :Number = 0; u <= 1; u += 1/100) {
//            posx = Math.pow(u,3)*(to.x+3*(control1.x-control2.x)-from.x)
//                +3*Math.pow(u,2)*(from.x-2*control1.x+control2.x)
//                +3*u*(control1.x-from.x)+from.x;
//
//            posy = Math.pow(u,3)*(to.y+3*(control1.y-control2.y)-from.y)
//                +3*Math.pow(u,2)*(from.y-2*control1.y+control2.y)
//                +3*u*(control1.y-from.y)+from.y;
//
//            graphics.lineTo(posx,posy);
//        }
//
//        //Let the curve end on the second anchorPoint
//        graphics.lineTo(to.x, to.y);
//    }

    public function removeStroke (strokeId :int) :void
    {
        if (strokeId in _layers) {
            var layer :Shape = _layers[strokeId];

            removeChild(layer);
            delete _layers[strokeId];
        }
    }

    public function clear () :void
    {
        for each (var shape :Shape in _layers) {
            removeChild(shape);
        }

        _layers = [];
        _continuations = [];
        _animations = [];
    }

    protected var _continuations :Array = []; // of ContinuationInfo
    protected var _layers :Array = []; // of Shape
    protected var _animations :Array = []; // of Array[BezierAnimation]
}

}
