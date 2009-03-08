package scribble.data {

import com.whirled.net.NetConstants;

public class Codes
{
    public static const BRUSH_COLORS :Array = [
        0xffffff,
        0x000000,
        0xff0000,
        0x0000ff,
        0xffff00,
        0x00ff00,
        0x964B00,
        0xff00ff,
        0xc0c0c0,
    ];

    public static const BRUSH_WIDTHS :Array = [
        8,
        4,
        4,
        4,
        4,
        4,
        4,
        4,
        4,
    ];

    // Different canvases/modes within a room, don't mess with these numbers
    public static const CANVAS_ROOM :int = 0;
    public static const CANVAS_PICTIONARY :int = 1;
    public static const CANVAS_EXHIBIT :int = 2;

    public static const CANVAS_PREFIXES :Array = [ NetConstants.makePersistent("0"), "1", "2" ];

    /** A room property (Dictionary) that maps playerId to canvasIndex. */
    public static const PLAYER_MODES :String = "mode";

    public static const MESSAGE_SECRET_WORD :String = "word"; // String, on Player
    public static const MESSAGE_CLEARED :String = "clear"; // int, on Room

    /** A dummy mob name and ID used for a correct foreground overlay drawing. */
    public static const MOB_FOREGROUND :String = "fg";

    /** Entity property to check if a canvas is lockable. */
    public static const PUBLIC_LOCKABLE :String = "scribble:lockable";

    public static function isAdmin (playerId :int) :Boolean
    {
        return playerId == 878; // Aduros' playerId
    }

    public static function keyCanvas (prefix :String) :String
    {
        return prefix + "canvas"; // Dictionary
    }

    public static function keyScores (prefix :String) :String
    {
        return prefix + "scores"; // Dictionary
    }

    public static function keyRoster (prefix :String) :String
    {
        return prefix + "roster"; // Dictionary
    }

    public static function keyTurnHolder (prefix :String) :String
    {
        return prefix + "turnHolder"; // int
    }

    public static function keyPhase (prefix :String) :String
    {
        return prefix + "phase"; // int
    }

    public static function keyTicker (prefix :String) :String
    {
        return prefix + "ticker"; // int
    }

    public static function keyLock (prefix :String) :String
    {
        return prefix + "lock"; // Boolean
    }
}

}
