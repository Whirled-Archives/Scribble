package scribble.server {

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.threerings.util.Sets;
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

    protected function requireWriteAccess (playerId :int) :void
        // throws Error
    {
        // See subclasses
    }
    
    public function toggleLock () :void
    {
        // Nothing by default, see subclasses
    }

    public function sendStroke (playerId :int, strokeBytes :ByteArray) :void
    {
        requireWriteAccess(playerId);

        addStroke(playerId, strokeBytes);
    }

    protected function addStroke (artistId :int, strokeBytes :ByteArray) :void
    {
        _props.setIn(Codes.keyCanvas(_prefix), _strokeCounter, [ artistId, strokeBytes ]);
        _strokeCounter += 1;
    }

    public function sendStrokeList (playerId :int, list :Array) :void
    {
        requireWriteAccess(playerId);

        for each (var strokeBytes :ByteArray in list) {
            addStroke(playerId, strokeBytes);
        }
    }

    public function removeStrokes (playerId :int, strokeIds :Array) :void
    {
        requireWriteAccess(playerId);

        for each (var strokeId :int in strokeIds) {
            _props.setIn(Codes.keyCanvas(_prefix), strokeId, null);
        }
    }

    public function clearCanvas (playerId :int) :void
    {
        requireWriteAccess(playerId);

        clear();
    }

    protected function clear () :void
    {
        _props.set(Codes.keyCanvas(_prefix), null);
        _strokeCounter = 0;
    }

    protected var _strokeCounter :int;

    // Set of playerIds that are currently in this mode
    protected var _players :Set = Sets.newSetOf(int); // playerId

    protected var _mode :int;
    protected var _prefix :String;
    protected var _props :PropertySubControl;
}

}
