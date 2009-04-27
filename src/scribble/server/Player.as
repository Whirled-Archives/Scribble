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

//        // TEMPORARY
//        // Prizes weren't being awarded, so give them out once to trophy owners
//        if (ctrl.props.get("@migration") < 1) {
//            ctrl.doBatch(function () :void {
//                for each (var trophy :Trophy in TROPHIES.backdropStrokes) {
//                    if (ctrl.holdsTrophy(trophy.id)) {
//                        ctrl.awardPrize(trophy.prize);
//                    }
//                }
//                ctrl.props.set("@migration", 1);
//            });
//        }
//        // END TEMPORARY
    }

    public function get ctrl () :PlayerSubControlServer
    {
        return _ctrl;
    }

    public function getName () :String
    {
        return ctrl.getPlayerName();
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
        pictoGuessLength: Stat.MAX, // Longest word ever guessed
        pictoNightWins: Stat.ADD,
        pictoCloseCall: Stat.SET,

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
            new Trophy(10, "roman2"),
            new Trophy(50, "roman3"),
            new Trophy(200, "roman4"),
            new Trophy(500, "roman5"),
            new Trophy(1000, "roman6"),
            new Trophy(2000, "roman7"),
        ],

        pictoWins: [
            new Trophy(1, "rainbow1"),
            new Trophy(5, "rainbow2"),
            new Trophy(25, "rainbow3"),
            new Trophy(50, "rainbow4"),
            new Trophy(100, "rainbow5"),
            new Trophy(200, "rainbow6"),
            new Trophy(500, "rainbow7"),
            new Trophy(1000, "rainbow8"),
        ],

        pictoDraws: [
            new Trophy(1, "paint1"),
            new Trophy(10, "paint2"),
            new Trophy(50, "paint3"),
            new Trophy(200, "paint4"),
            new Trophy(500, "paint5"),
            new Trophy(1000, "paint6"),
            new Trophy(2000, "paint7"),
        ],

        pictoGuesses: [
            new Trophy(5, "books1"),
            new Trophy(25, "books2"),
            new Trophy(150, "books3"),
            new Trophy(600, "books4"),
            new Trophy(1500, "books5"),
            new Trophy(3000, "books6"),
            new Trophy(5000, "books7"),
        ],

        pictoScore: [
            new Trophy(30, "medal1"),
            new Trophy(50, "medal2"),
            new Trophy(80, "medal3"),
        ],

        pictoColors: [ new Trophy(6, "colors") ],
        pictoGuessLength: [ new Trophy(14, "dictionary") ],
        pictoNightWins: [ new Trophy(5, "nightowl") ],
        pictoBoobs: [ new Trophy(true, "boobeyes") ],
        pictoCloseCall: [ new Trophy(true, "watch") ],
        pictoQuickDraw: [ new Trophy(true, "quickdraw") ],
        pictoQuickGuess: [ new Trophy(true, "quickguess") ],

        // Only updated in multiples of 10
        backdropStrokes: [
            new Trophy(10, "scribble1", "thumper"), // Amateur painter
            new Trophy(200, "scribble2", "popper"), // Aspiring painter
            new Trophy(1000, "scribble3", "highway"), // Apprentice painter
            new Trophy(2000, "scribble4", "feeder"), // Journeyman painter
            new Trophy(5000, "scribble5", "pixeltar"), // Master Artist
            new Trophy(10000, "scribble6", "babel"), // Celebrated Artist
            new Trophy(20000, "scribble7", "quakemix"), // Whirled-renown Artist
        ],

        killedMonster: [ new Trophy(true, "sword") ],
        boughtToolbox: [ new Trophy(true, "toolbox") ]
    };

    protected var _ctrl :PlayerSubControlServer;

    protected var _backdropStrokes :int;
}


}
