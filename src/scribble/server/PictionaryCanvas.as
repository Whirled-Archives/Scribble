package scribble.server {

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.whirled.avrg.*;
import com.whirled.net.*;

import scribble.data.Codes;
import scribble.data.PictionaryLogic;

public class PictionaryCanvas extends Canvas
{
    public function PictionaryCanvas (mode :int, room :RoomManager)
    {
        super(mode, room.ctrl.props);

        _room = room;
        _ticker = new Ticker(_props, Codes.keyTicker(_prefix));

        _logic = new PictionaryLogic(_prefix, _props);

        _room.ctrl.addEventListener(AVRGameRoomEvent.ROOM_UNLOADED, onRoomUnloaded);

        _props.set(Codes.keyPhase(_prefix), null, true);
    }

    protected function setPhase (phase :int) :void
    {
        if (phase == _logic.getPhase()) {
            throw new Error("Can't switch to the same phase!");
        }

        _props.set(Codes.keyPhase(_prefix), phase, true);

        switch (phase) {
            case PictionaryLogic.PHASE_INTERMISSION:
                _props.set(Codes.keyTurnHolder(_prefix), null, true);
                _round = 0;
                _ticker.start(20, true, function () :void {
                    purgeMissingPlayers();
                    _props.set(Codes.keyScores(_prefix), null, true);
                    nextTurn();
                });
                break;

            case PictionaryLogic.PHASE_PAUSE:
                _ticker.start(5, false, nextTurn);
                break;

            case PictionaryLogic.PHASE_PLAYING:
                _ticker.start(10, true, function () :void {
                    setPhase(PictionaryLogic.PHASE_PAUSE);
                });
                break;

            case PictionaryLogic.PHASE_NOT_ENOUGH_PLAYERS:
                _ticker.stop();
                break;
        }
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
            setPhase(PictionaryLogic.PHASE_INTERMISSION);
        }
    }

    override public function playerDidClose (playerId :int) :void
    {
        super.playerDidClose(playerId);

        if (_players.size() == PictionaryLogic.PLAYERS_REQUIRED-1) {
            setPhase(PictionaryLogic.PHASE_NOT_ENOUGH_PLAYERS);

        } else if (_logic.getTurnHolder() == _logic.getRosterId(playerId)) {
            setPhase(PictionaryLogic.PHASE_PAUSE);
        }
    }

    override protected function requireWriteAccess (playerId :int) :void
        // throws Error
    {
        if (!_logic.canDraw(playerId)) {
            throw new Error("Permission denied. Are you the turn holder?");
        }
    }

    /** Remove players not in this room from the roster. */
    protected function purgeMissingPlayers () :void
    {
        var roster :Dictionary = _logic.getRoster();

        for (var rosterId :String in roster) {
            if (!(roster[rosterId] in _room.players)) {
                _props.setIn(Codes.keyRoster(_prefix), int(rosterId), null, true);
            }
        }
    }

    protected function nextTurn () :void
    {
        clear();

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

        var player :Player = _room.players[roster[turnHolder]];

        _props.set(Codes.keyTurnHolder(_prefix), turnHolder, true);

        // TODO
        player.mode.apply("sendWord", "writeme");

        // TODO: temp
        _props.setIn(Codes.keyScores(_prefix), turnHolder, int(_logic.getScores()[turnHolder])+1, true);

        setPhase(PictionaryLogic.PHASE_PLAYING);
    }

    public function pass (playerId :int) :void
    {
        requireWriteAccess(playerId);

        // TODO
    }

    protected function onRoomUnloaded (event :AVRGameRoomEvent) :void
    {
        // Clean up?
        _ticker.stop();
    }

    public static function createWordList (ba :ByteArray) :void
    {
        try {
            ba.position = 0; // TODO: Remove once Whirled rewinds for you
            _words = ba.readUTFBytes(ba.length).split("\n");
            Server.log.info("Word list created", "length", _words.length);

        } catch (error :Error) {
            Server.log.error("Word list parsing failed!", error);
        }
    }

    protected static var _words :Array;

    protected var _room :RoomManager;
    protected var _ticker :Ticker;
    protected var _logic :PictionaryLogic;

    /** Matches are made up of multiple rounds. This property isn't distributed. */
    protected var _round :int;
}

}
