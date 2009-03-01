package scribble.server {

import com.threerings.util.Hashable;

import com.whirled.avrg.*;

public class Player
    implements Hashable
{
    public var room :RoomManager;

    public function Player (ctrl :PlayerSubControlServer)
    {
        _ctrl = ctrl;
    }

    public function get ctrl () :PlayerSubControlServer
    {
        return _ctrl;
    }

    public function getName () :String
    {
        return room.ctrl.getAvatarInfo(_ctrl.getPlayerId()).name;
    }

    public function equals (other :Object) :Boolean
    {
        return hashCode() == other.hashCode();
    }

    public function hashCode () :int
    {
        return _ctrl.getPlayerId();
    }

    public var _ctrl :PlayerSubControlServer;
}

}
