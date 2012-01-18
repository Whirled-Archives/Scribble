package scribble.client {

import flash.display.Sprite;
import flash.display.GradientType;
import flash.geom.Matrix;

public class Wedge extends Sprite
{
    public function Wedge (radius :Number)
    {
        _radius = radius;

        // Because the code I copy-pasta'd doesn't work as advertised
        var matrix :Matrix = new Matrix();
        matrix.scale(-1, 1);
        matrix.rotate(Math.PI/2);
        matrix.translate(_radius, _radius);

        this.transform.matrix = matrix;
    }

    /** Punked from http://code.google.com/p/leebrimelow/source/browse/trunk/as3/com/theflashblog/drawing/Wedge.as */
    protected function redraw () :void
    {
        graphics.clear();
        graphics.beginGradientFill(GradientType.LINEAR, [0xff6600, 0xffdd00], [1, 1], [0, 255]);
        graphics.lineStyle(3, 0xffffff);

        var segAngle:Number;
        var angle:Number = 0;
        var angleMid:Number;
        var numOfSegs:Number;
        var ax:Number;
        var ay:Number;
        var bx:Number;
        var by:Number;
        var cx:Number;
        var cy:Number;

        numOfSegs = Math.ceil(Math.abs(_arc) / 45);
        segAngle = _arc / numOfSegs;
        segAngle = (segAngle / 180) * Math.PI;

        // Calculate the start point
        ax = Math.cos(angle) * _radius;
        ay = Math.sin(-angle) * _radius;

        // Draw the first line
        graphics.lineTo(ax, ay);

        for (var i:int=0; i<numOfSegs; i++) {
            angle += segAngle;
            angleMid = angle - (segAngle / 2);
            bx = Math.cos(angle) * _radius;
            by = Math.sin(angle) * _radius;
            cx = Math.cos(angleMid) * (_radius / Math.cos(segAngle / 2));
            cy = Math.sin(angleMid) * (_radius / Math.cos(segAngle / 2));
            graphics.curveTo(cx, cy, bx, by);
        }

        // Close the wedge
        graphics.lineTo(0, 0);

        graphics.endFill();
    }

    public function set arc (arc :Number) :void
    {
        _arc = Math.min(arc, 360);
        redraw();
    }

    public function get arc () :Number
    {
        return _arc;
    }

    protected var _arc :Number;
    protected var _radius :Number;
}

}
