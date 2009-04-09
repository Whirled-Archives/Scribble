package scribble.data {

import com.whirled.avrg.PlayerSubControlBase;
import com.whirled.net.NetConstants;

public class Codes
{
    public static const TICKER_GRANULARITY :int = 5000;

    // Different canvases/modes within a room, don't mess with these numbers
    public static const CANVAS_ROOM :int = 0;
    public static const CANVAS_PICTIONARY :int = 1;
    public static const CANVAS_EXHIBIT :int = 2;

    public static const CANVAS_PREFIXES :Array = [ NetConstants.makePersistent("0"), "1", "2" ];

    /** A room property (Dictionary) that maps playerId to canvasIndex. */
    public static const PLAYER_MODES :String = "m";

    /** A dummy mob name and ID used for a correct foreground overlay drawing. */
    public static const MOB_FOREGROUND :String = "fg";

    /** Player property storing the last swf MD5 hash played. */
    public static const PLAYER_VERSION :String = NetConstants.makePersistent("v");

    public static const PUBLIC_TOOLBENCH :String = "scribble:toolbench";

    /** Lobby rooms used by LoadBalancer. */
    public static const LOBBIES :Array = [ 666 ]; // TODO

    /** Parlor rooms used by LoadBalancer. */
    public static const PARLORS :Array = [ 999 ]; // TODO

    public static function isAdmin (playerId :int) :Boolean
    {
        return playerId == 878  // Aduros
            || playerId == 713; // Silk
    }

    public static function hasToolboxUpgrade (ctrl :PlayerSubControlBase) :Boolean
    {
        for each (var pack :Object in ctrl.getPlayerItemPacks()) {
            if (pack.ident == "toolbox") {
                return true;
            }
        }
        return false;
    }

    public static function keyCanvas (prefix :String) :String
    {
        return prefix + "a"; // Dictionary
    }

    public static function keyScores (prefix :String) :String
    {
        return prefix + "b"; // Dictionary
    }

    public static function keyRoster (prefix :String) :String
    {
        return prefix + "c"; // Dictionary
    }

    public static function keyTurnHolder (prefix :String) :String
    {
        return prefix + "d"; // int
    }

    public static function keyPhase (prefix :String) :String
    {
        return prefix + "e"; // int
    }

    public static function keyTicker (prefix :String) :String
    {
        return prefix + "f"; // int
    }

    public static function keyLock (prefix :String) :String
    {
        return prefix + "g"; // Boolean
    }

    public static function keyHint (prefix :String) :String
    {
        return prefix + "h"; // Boolean
    }

    public static function msgCleared (prefix :String) :String
    {
        return prefix + "a"; // int
    }

    public static function msgPass (prefix :String) :String
    {
        return prefix + "b"; // String
    }

    public static function msgCorrect (prefix :String) :String
    {
        return prefix + "c"; // [int, String]
    }

    public static function msgFail (prefix :String) :String
    {
        return prefix + "d"; // String
    }

    public static function msgWinners (prefix :String) :String
    {
        return prefix + "e"; // [String]
    }
}

}
