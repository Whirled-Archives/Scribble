package scribble.client {

import flash.events.Event;

import scribble.data.Stroke;

public class StrokeEvent extends Event
{
    public static const STROKE_ADDED :String = "StrokeAdded";
    public static const STROKE_REMOVED :String = "StrokeRemoved"; // Unused

    public var stroke :Stroke;
    public var strokeId :int;
    public var artistId :int;

    public function StrokeEvent (type :String)
    {
        super(type);
    }

    public function isMyStroke () :Boolean
    {
        return artistId == Game.ctrl.player.getPlayerId();
    }
}

}
