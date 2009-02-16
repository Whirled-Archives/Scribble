package scribble.client {

import flash.geom.Point;

/** Represents a cubic bezier curve. */
public class BezierCurve
{
    public var from :Point;
    public var control1 :Point;
    public var control2 :Point;
    public var to :Point;

    public function BezierCurve (from :Point, control1 :Point, control2 :Point, to :Point)
    {
        this.from = from;
        this.control1 = control1;
        this.control2 = control2;
        this.to = to;
    }
}

}
