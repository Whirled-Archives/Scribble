package scribble.server {

import flash.utils.Dictionary;

import com.whirled.avrg.*;
import com.whirled.net.*;

import scribble.data.Codes;
import scribble.data.PictionaryLogic;

public class PictionaryCanvas extends Canvas
{
    public function PictionaryCanvas (mode :int, ctrl :RoomSubControlServer)
    {
        super(mode, ctrl.props);

        _ctrl = ctrl;
        _ticker = new Ticker(_ctrl.props, Codes.keyTicker(_prefix));

        _logic = new PictionaryLogic(_prefix, _props);

        _ctrl.addEventListener(AVRGameRoomEvent.ROOM_UNLOADED, onRoomUnloaded);

        _props.set(Codes.keyPhase(_prefix), null, true);
        //setPhase(Codes.PHASE_NOT_ENOUGH_PLAYERS);
        //setPhase(-1);
    }

    protected function setPhase (phase :int) :void
    {
        if (phase == _logic.getPhase()) {
            throw new Error("Can't switch to the same phase!");
        }

        switch (phase) {
            case Codes.PHASE_INTERMISSION:
                purgeMissingPlayers();
                _props.set(Codes.keyTurnHolder(_prefix), null, true);
                _round = 0;
                _ticker.start(20, true, nextTurn);
                break;

            case Codes.PHASE_PAUSE:
                _ticker.start(5, false, nextTurn);
                break;

            case Codes.PHASE_PLAYING:
                _ticker.start(10, true, function () :void {
                    setPhase(Codes.PHASE_PAUSE);
                });
                break;

            case Codes.PHASE_NOT_ENOUGH_PLAYERS:
                _ticker.stop();
                break;
        }

        _props.set(Codes.keyPhase(_prefix), phase, true);
    }

    override public function playerDidOpen (playerId :int) :void
    {
        super.playerDidOpen(playerId);

        var roster :Dictionary = Dictionary(_props.get(Codes.keyRoster(_prefix)));

        if (_logic.getRosterId(playerId) < 0) {
            // This is the player's first time opening
            var rosterId :int = getInsertIndex(Codes.keyRoster(_prefix));
            _props.setIn(Codes.keyRoster(_prefix), rosterId, playerId, true);
        }

        if (_players.size() == PictionaryLogic.PLAYERS_REQUIRED) {
            setPhase(Codes.PHASE_INTERMISSION);
        }
    }

    override public function playerDidClose (playerId :int) :void
    {
        super.playerDidClose(playerId);

        if (_players.size() == PictionaryLogic.PLAYERS_REQUIRED-1) {
            setPhase(Codes.PHASE_NOT_ENOUGH_PLAYERS);

        } else if (_logic.getTurnHolder() == _logic.getRosterId(playerId)) {
            setPhase(Codes.PHASE_PAUSE);
        }
    }

    override protected function requireWriteAccess (player :Player) :void // throws Error
    {
        if (!_logic.canDraw(player.ctrl.getPlayerId())) {
            throw new Error("Permission denied. Are you the turn holder?");
        }
    }

    /** Remove players not in this room from the roster. */
    protected function purgeMissingPlayers () :void
    {
        var roster :Dictionary = _logic.getRoster();

        for (var rosterId :String in roster) {
            if (!_ctrl.isPlayerHere(int(roster[rosterId]))) {
                _props.setIn(Codes.keyRoster(_prefix), int(rosterId), null, true);
            }
        }
    }

    protected function nextTurn () :void
    {
        var turnHolder :int = _logic.getTurnHolder();
        var roster :Dictionary = _logic.getRoster();
        var end :int = getInsertIndex(Codes.keyRoster(_prefix));

        do {
            turnHolder += 1;
            if (turnHolder == end) {
//                _cycle += 1;
//                if (_cycle < 3) {
                    turnHolder = 0;
//                }
            }
        } while (!_players.contains(roster[turnHolder]));

        _props.set(Codes.keyTurnHolder(_prefix), turnHolder, true);
        _props.setIn(Codes.keyScores(_prefix), turnHolder, int(_logic.getScores()[turnHolder])+1, true);

        setPhase(Codes.PHASE_PLAYING);
    }

    public function pass (player :Player) :void
    {
        requireWriteAccess(player);
    }

    protected function onRoomUnloaded (event :AVRGameRoomEvent) :void
    {
        // Clean up
        _ticker.stop();
    }

    protected var _ctrl :RoomSubControlServer;
    protected var _ticker :Ticker;
    protected var _logic :PictionaryLogic;

    /** Matches are made up of multiple rounds. This property isn't distributed. */
    protected var _round :int;
}

}
