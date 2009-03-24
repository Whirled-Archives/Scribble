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

    public function addedBackdropStroke () :void
    {
        // Only submit a stat every 10 strokes to save messages
        _backdropStrokes += 1;
        if (_backdropStrokes >= 10) {
            stats.submit("backdropStrokes", 10);
            _backdropStrokes = 0;
        }
    }

    protected static const STATS :Object = {
        pictoScore: Stat.MAX, // High score in pictionary
        pictoWins: Stat.ADD, // Pictionary rounds won
        pictoRounds: Stat.ADD, // Pictionary rounds played
        pictoDraws: Stat.ADD, // Pictionary words successfully drawn
        pictoGuesses: Stat.ADD, // Pictionary words successfully guessed
        pictoBoobs: Stat.SET, // ( . Y . )
//        pictoConsecutives: Stat.MAX, // Number of rounds played in a single session
        pictoColors: Stat.MAX, // Number of colors used in a single drawing

        pictoQuickDraw: Stat.SET,
        pictoQuickGuess: Stat.SET,

//        backdropTime: Stat.ADD, // Total minutes spent in backdrop mode
        backdropStrokes: Stat.ADD, // Total strokes sent to backdrop mode

        boughtToolbox: Stat.SET,
        killedMonster: Stat.SET // o==(--------
    };
    protected static const TROPHIES :Object = {
        pictoRounds: [
            new Trophy(1, "roman1"),
            new Trophy(2, "roman2"),
            new Trophy(3, "roman3"),
            new Trophy(4, "roman4"),
            new Trophy(5, "roman5"),
            new Trophy(6, "roman6"),
            new Trophy(7, "roman7"),
        ],

        pictoWins: [
            new Trophy(1, "rainbow1"),
            new Trophy(2, "rainbow2"),
            new Trophy(3, "rainbow3"),
            new Trophy(4, "rainbow4"),
            new Trophy(5, "rainbow5"),
            new Trophy(6, "rainbow6"),
            new Trophy(7, "rainbow7"),
        ],

        pictoDraws: [
            new Trophy(1, "paint1"),
            new Trophy(2, "paint2"),
            new Trophy(3, "paint3"),
            new Trophy(4, "paint4"),
            new Trophy(5, "paint5"),
            new Trophy(6, "paint6"),
            new Trophy(7, "paint7"),
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
            new Trophy(10, "medal1"),
            new Trophy(20, "medal2"),
            new Trophy(30, "medal3"),
        ],

        pictoColors: [ new Trophy(6, "colors") ],

        // Only updated in multiples of 10
        backdropStrokes: [
            new Trophy(10, "scribble1"), // TODO: Also award a prize
            new Trophy(20, "scribble2"),
            new Trophy(30, "scribble3"),
            new Trophy(40, "scribble4"),
            new Trophy(50, "scribble5"),
            new Trophy(60, "scribble6"),
            new Trophy(70, "scribble7"),
        ],

        pictoBoobs: [ new Trophy(true, "boobeyes") ],
        pictoQuickDraw: [ new Trophy(true, "quickdraw") ],
        pictoQuickGuess: [ new Trophy(true, "quickguess") ],
        boughtToolbox: [ new Trophy(true, "toolbox") ],
        killedMonster: [ new Trophy(true, "sword") ]
    };

    protected var _ctrl :PlayerSubControlServer;

    protected var _backdropStrokes :int;
}


}
