package scribble.data {

import flash.utils.Dictionary;

import com.whirled.net.PropertyGetSubControl;

/** Logic for pictionary used by both the client and server. */
public class PictionaryLogic
{
    /** Players required to start. */
    public static const PLAYERS_REQUIRED :int = 2;

    // Phases within the game
    public static const PHASE_NOT_ENOUGH_PLAYERS :int = 0;
    public static const PHASE_INTERMISSION :int = 1;
    public static const PHASE_PLAYING :int = 2;
    public static const PHASE_PAUSE :int = 3;

    public function PictionaryLogic (prefix :String, props :PropertyGetSubControl)
    {
        _prefix = prefix;
        _props = props;
    }

    /** The current turn holder. This is a rosterId and NOT a playerId! */
    public function getTurnHolder () :int
    {
        switch (getPhase()) {
            case PHASE_NOT_ENOUGH_PLAYERS:
            case PHASE_INTERMISSION:
                return -1; // No turn holder for these phases
            default:
                return int(_props.get(Codes.keyTurnHolder(_prefix)));
        }
    }

    public function getRoster () :Dictionary
    {
        return Dictionary(_props.get(Codes.keyRoster(_prefix)));
    }

    public function getRosterId (playerId :int) :int
    {
        var roster :Dictionary = getRoster();

        for (var rosterId :String in roster) {
            if (roster[rosterId] == playerId) {
                return int(rosterId);
            }
        }
        return -1;
    }

    public function getPhase () :int
    {
        return int(_props.get(Codes.keyPhase(_prefix)));
    }

    public function getScores () :Dictionary
    {
        var scores :Dictionary = Dictionary(_props.get(Codes.keyScores(_prefix)));
        return (scores != null) ? scores : new Dictionary();
    }
    
    public function canDraw (playerId :int) :Boolean
    {
        // TODO: Convert playerId to rosterId, check phase and turnholder
        return true;
    }

    protected var _prefix :String;
    protected var _props :PropertyGetSubControl;
}

}
