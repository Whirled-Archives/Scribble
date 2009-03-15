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
                _ticker.start(PictionaryLogic.DELAY_INTERMISSION, true, function () :void {
                    purgeMissingPlayers();
                    _props.set(Codes.keyScores(_prefix), null, true);
                    nextTurn();
                });
                break;

            case PictionaryLogic.PHASE_PAUSE:
                _ticker.start(PictionaryLogic.DELAY_PAUSE, false, nextTurn);
                break;

            case PictionaryLogic.PHASE_PLAYING:
                _ticker.start(PictionaryLogic.DELAY_PLAYING, true, function () :void {
                    _room.ctrl.sendMessage(Codes.msgFail(_prefix), WORD_LIST[_wordId]);
                    setPhase(PictionaryLogic.PHASE_PAUSE);
                }, onPlayProgress);
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

    protected function hintLetter (hint :String, n :int = -1) :String
    {
        if (hint.indexOf("-") == -1) {
            return hint;
        }

        if (n < 0) {
            do {
                n = Math.random()*hint.length;
            } while (hint.charAt(n) != "-" && hint.charAt(n) != " ");
        }

        return hint.substr(0, n) + WORD_LIST[_wordId].charAt(n) + hint.substr(n+1);
    }

    protected function onPlayProgress (tick :int) :void
    {
        if (tick/PictionaryLogic.DELAY_PLAYING > (1/3)) {
            var hintPoint :int = (2/3)*(PictionaryLogic.DELAY_PLAYING/(0.75*_wordClean.length));
            if (tick%hintPoint == 0) {
                var hint :String = _props.get(Codes.keyHint(_prefix)) as String;

                if (hint == null) {
                    hint = WORD_LIST[_wordId].replace(/[^ ]/g, "-");
                    hint = hintLetter(hint, 0);
                } else {
                    hint = hintLetter(hint);
                }

                _props.set(Codes.keyHint(_prefix), hint);
            }
        }
    }

    protected function nextTurn () :void
    {
        clear();
        _props.set(Codes.keyHint(_prefix), null);

        var turnHolder :int = _logic.getTurnHolder();
        var roster :Dictionary = _logic.getRoster();
        var end :int = getInsertIndex(Codes.keyRoster(_prefix));

        do {
            turnHolder += 1;
            if (turnHolder == end) {
                _round += 1;
                if (_round == PictionaryLogic.ROUNDS) {
                    setPhase(PictionaryLogic.PHASE_INTERMISSION);
                    // TODO: Declare winner, payouts, etc
                    return;
                } else {
                    turnHolder = 0;
                }
            }
        } while (!_players.contains(roster[turnHolder]));

        _wordId = Math.random()*WORD_LIST.length;
        _wordClean = cleanupWord(WORD_LIST[_wordId]);

        var player :Player = _room.players[roster[turnHolder]];
        player.modeReceiver.apply("sendWord", WORD_LIST[_wordId]);

        _props.set(Codes.keyTurnHolder(_prefix), turnHolder, true);

        setPhase(PictionaryLogic.PHASE_PLAYING);
    }

    public function pass (playerId :int) :void
    {
        requireWriteAccess(playerId);

        if (_logic.getPhase() != PictionaryLogic.PHASE_PLAYING) {
            throw new Error("Game should be in the PLAYING phase");
        }

        _room.ctrl.sendMessage(Codes.msgPass(_prefix), WORD_LIST[_wordId]);

        setPhase(PictionaryLogic.PHASE_PAUSE);
    }

    protected function addScore (rosterId :int, delta :int) :void
    {
        _props.setIn(Codes.keyScores(_prefix), rosterId,
            int(_logic.getScores()[rosterId])+delta, true);
    }

    public function guess (playerId :int, guess :String) :void
    {
        if (!_logic.canGuess(playerId)) {
            throw new Error("Not allowed to guess");
        }

        var turnHolder :int = _logic.getTurnHolder();
        var rosterId :int = _logic.getRosterId(playerId);

        if (cleanupWord(guess) == _wordClean) {
            var roster :Dictionary = _logic.getRoster();
            var guesser :Player = _room.players[roster[turnHolder]];
            var drawer :Player = _room.players[roster[rosterId]];

            var frac :Number = int(_props.get(Codes.keyTicker(_prefix)))/PictionaryLogic.DELAY_PLAYING;
            var points :int = 9*(1-frac) + 1;

            addScore(rosterId, points);
            addScore(turnHolder, points);

            // Notify correct guess
            _room.ctrl.sendMessage(
                Codes.msgCorrect(_prefix), [ playerId, WORD_LIST[_wordId], points ]);

            // TODO: Payout guesser and drawer

            setPhase(PictionaryLogic.PHASE_PAUSE);
        }
    }

    protected function cleanupWord (word :String) :String
    {
        return word.replace(" ", "").toLowerCase();
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
            WORD_LIST = ba.readUTFBytes(ba.length).split("\n");
            Server.log.info("Word list created", "length", WORD_LIST.length);

        } catch (error :Error) {
            Server.log.error("Word list parsing failed!", error);
        }
    }

    protected static var WORD_LIST :Array; // of String

    protected var _wordId :int; // An index into WORD_LIST
    protected var _wordClean :String; // A cleaned up version of the current secret word

    protected var _room :RoomManager;
    protected var _ticker :Ticker;
    protected var _logic :PictionaryLogic;

    /** Matches are made up of multiple rounds. This property isn't distributed. */
    protected var _round :int;
}

}
