package scribble.data {

import flash.geom.Point;
import flash.utils.ByteArray;

public class Stroke
{
    public var points :Array = []; // of Point

    public var isBeginning :Boolean;
    public var isEnding :Boolean;

    /** Index to Codes.BRUSHES. */
    public var brush :int;

    public function toBytes () :ByteArray
    {
        var ba :ByteArray = new ByteArray();

        ba.writeInt(points.length);
        for each (var point :Point in points) {
            ba.writeInt(point.x);
            ba.writeInt(point.y);
        }

        var flags :int;
        if (isBeginning) {
            flags |= 4;
        }
        if (isEnding) {
            flags |= 2;
        }
        if (brush < 0) {
            flags |= 1;
        }
        ba.writeByte(flags);
        ba.writeByte(Math.abs(brush)-128); // Surprise! This takes a signed byte

        return ba;
    }

    public static function fromBytes (ba :ByteArray) :Stroke
    {
        var stroke :Stroke = new Stroke();

        stroke.points = new Array(ba.readInt());
        for (var ii :int = 0; ii < stroke.points.length; ++ii) {
            stroke.points[ii] = new Point(ba.readInt(), ba.readInt());
        }

        var flags :int = ba.readByte();
        stroke.isBeginning = (flags & 4) != 0;
        stroke.isEnding = (flags & 2) != 0;

        stroke.brush = ba.readByte()+128;
        if (flags & 1) {
            stroke.brush = -stroke.brush;
        }

        ba.position = 0; // Be kind, rewind

        return stroke;
    }
}

}
