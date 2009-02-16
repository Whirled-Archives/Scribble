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
        ba.writeBoolean(isBeginning);
        ba.writeBoolean(isEnding);
        ba.writeByte(brush);

        return ba;
    }

    public static function fromBytes (ba :ByteArray) :Stroke
    {
        var stroke :Stroke = new Stroke();

        stroke.points = new Array(ba.readInt());
        for (var ii :int = 0; ii < stroke.points.length; ++ii) {
            stroke.points[ii] = new Point(ba.readInt(), ba.readInt());
        }
        stroke.isBeginning = ba.readBoolean();
        stroke.isEnding = ba.readBoolean();
        stroke.brush = ba.readByte();

        ba.position = 0; // Be kind, rewind

        return stroke;
    }
}

}
