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
        pictoBoobs: Stat.SET, // ( . Y . )
        pictoConsecutives: Stat.MAX, // Number of rounds played in a single session
        pictoColors: Stat.MAX, // Number of colors used in a single drawing

        //backdropTime: Stat.ADD, // Total minutes spent in backdrop mode
        backdropStrokes: Stat.ADD, // Total strokes sent to backdrop mode

        boughtToolbox: Stat.SET,
        killedMonster: Stat.SET // o==(--------
    };
    protected static const TROPHIES :Object = {
//        pictoDraws: [ new Trophy(1, "pictoDraws1"), new Trophy(3, "pictoDraws3") ] // Test
        pictoRounds: [
            new Trophy(1, "pictoRounds1"),
            new Trophy(2, "pictoRounds2"),
            new Trophy(3, "pictoRounds3"),
            new Trophy(4, "pictoRounds4"),
            new Trophy(5, "pictoRounds5"),
            new Trophy(6, "pictoRounds6"),
            new Trophy(7, "pictoRounds7"),
        ],

        pictoWins: [
            new Trophy(1, "pictoWins1"),
            new Trophy(2, "pictoWins2"),
            new Trophy(3, "pictoWins3"),
            new Trophy(4, "pictoWins4"),
            new Trophy(5, "pictoWins5"),
            new Trophy(6, "pictoWins6"),
            new Trophy(7, "pictoWins7"),
        ],

        pictoDraws: [
            new Trophy(1, "pictoDraws1"),
            new Trophy(2, "pictoDraws2"),
            new Trophy(3, "pictoDraws3"),
            new Trophy(4, "pictoDraws4"),
            new Trophy(5, "pictoDraws5"),
            new Trophy(6, "pictoDraws6"),
            new Trophy(7, "pictoDraws7"),
        ],

        pictoGuesses: [
            new Trophy(1, "pictoGuesses1"),
            new Trophy(2, "pictoGuesses2"),
            new Trophy(3, "pictoGuesses3"),
            new Trophy(4, "pictoGuesses4"),
            new Trophy(5, "pictoGuesses5"),
            new Trophy(6, "pictoGuesses6"),
            new Trophy(7, "pictoGuesses7"),
        ],

        pictoScore: [
            new Trophy(1, "pictoScore1"),
            new Trophy(2, "pictoScore2"),
            new Trophy(3, "pictoScore3"),
        ],

        pictoBoobs: [ new Trophy(true, "pictoBoobs") ],

        boughtToolbox: [ new Trophy(true, "boughtToolbox") ],
        killedMonster: [ new Trophy(true, "killedMonster") ]
    };

    protected var _ctrl :PlayerSubControlServer;
}


}
