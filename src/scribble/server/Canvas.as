package scribble.server {

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.threerings.util.HashSet;
import com.threerings.util.Set;

import com.whirled.avrg.*;
import com.whirled.net.*;

import scribble.data.Codes;

public class Canvas
{
    public function Canvas (mode :int, props :PropertySubControl)
    {
        _mode = mode;
        _prefix = Codes.CANVAS_PREFIXES[_mode];
        _props = props;

        _strokeCounter = getInsertIndex(Codes.keyCanvas(_prefix));

        //_props.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onRoomElementChanged);
    }

    /** Handy dandy. */
    protected function getInsertIndex (listName :String) :int
    {
        var index :int = 0;
        for (var key :String in Dictionary(_props.get(listName))) {
            index = Math.max(index, int(key)+1);
        }
        return index;
    }

//    protected function onRoomElementChanged (event :ElementChangedEvent) :void
//    {
//        trace("Got an element change at least!");
//        if (event.name == Codes.PLAYER_MODES) {
//            var playerId :int = event.key;
//            trace("... and it was a mode change for " + playerId);
//            if (event.oldValue == _mode) {
//                _players.remove(playerId);
//                playerDidClose(playerId);
//            }
//            if (event.newValue == _mode) {
//                _players.add(playerId);
//                playerDidOpen(playerId);
//            }
//        }
//    }

    public function playerDidClose (playerId :int) :void
    {
        // Call super!
        _players.remove(playerId);
    }

    public function playerDidOpen (playerId :int) :void
    {
        // Call super!
        _players.add(playerId);
    }

    protected function requireWriteAccess (player :Player) :void // throws Error
    {
        // See subclasses
    }

    public function sendStroke (player :Player, strokeBytes :ByteArray) :void
    {
        requireWriteAccess(player);

        _props.setIn(Codes.keyCanvas(_prefix), _strokeCounter,
            [ player.ctrl.getPlayerId(), strokeBytes ]);
        _strokeCounter += 1;
    }

    public function sendStrokeList (player :Player, list :Array) :void
    {
        for each (var strokeBytes :ByteArray in list) {
            sendStroke(player, strokeBytes);
        }
    }

    public function removeStrokes (player :Player, strokeIds :Array) :void
    {
        requireWriteAccess(player);

        for each (var strokeId :int in strokeIds) {
            _props.setIn(Codes.keyCanvas(_prefix), strokeId, null);
        }
    }

    public function clearCanvas (player :Player) :void
    {
        requireWriteAccess(player);

        _props.set(Codes.keyCanvas(_prefix), null);
        _strokeCounter = 0;
    }

    protected var _strokeCounter :int;

    // Set of playerIds that are currently in this mode
    protected var _players :Set = new HashSet(); // of playerId

    protected var _mode :int;
    protected var _prefix :String;
    protected var _props :PropertySubControl;
}

}
