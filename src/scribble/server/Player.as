package scribble.server {

import com.threerings.util.Hashable;

import com.whirled.avrg.*;

import aduros.net.RemoteCaller;
import aduros.game.*;

public class Player
    implements Hashable
{
    public var room :RoomManager;

    public var modeReceiver :RemoteCaller;
    public var playerReceiver :RemoteCaller;

    public var stats :StatTracker;

    public function Player (ctrl :PlayerSubControlServer)
    {
        _ctrl = ctrl;

        modeReceiver = new RemoteCaller(_ctrl, "mode");
        playerReceiver = new RemoteCaller(_ctrl, "player");

        stats = new StatTracker(STATS, TROPHIES, ctrl);
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

    protected static const STATS :Object = {
        pictoScore: Stat.MAX, // High score in pictionary
        pictoWins: Stat.ADD, // Pictionary rounds won
        pictoRounds: Stat.ADD, // Pictionary rounds played
        pictoDraws: Stat.ADD, // Pictionary words successfully drawn
        pictoGuesses: Stat.ADD, // Pictionary words successfully guessed
        pictoBoobed: Stat.SET
    };
    protected static const TROPHIES :Object = {
        pictoScore: [ new Trophy(20, "pictoScore8") ], // Test
        pictoBoobed: [ new Trophy(true, "pictoBoobed") ],
        pictoDraws: [ new Trophy(1, "pictoDraws1"), new Trophy(3, "pictoDraws3") ] // Test
    };

    protected var _ctrl :PlayerSubControlServer;
}


}
