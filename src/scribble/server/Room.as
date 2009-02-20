package scribble.server {

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Set;

import com.whirled.avrg.*;
import com.whirled.net.*;

import scribble.data.Codes;

public class Room
{
    public function Room (ctrl :RoomSubControlServer)
    {
        _ctrl = ctrl;

        // Reinitialize memory. It turns out if a game is rebooted by the owner uploading a new
        // version, non-persistent memory sticks around! 
        _ctrl.props.set(Codes.PLAYER_MODES, null, true);

        _ctrl.addEventListener(AVRGameRoomEvent.PLAYER_LEFT, onPlayerLeft);

        // TODO: Handle this better
        //_ctrl.addEventListener(AVRGameRoomEvent.ROOM_UNLOADED, function (... _) :void {
        //    _ctrl.props.set("game", null);
        //});

        _pictionary = new PictionaryCanvas(1, this);

        _canvases.push(new Canvas(0, _ctrl.props));
        _canvases.push(_pictionary);
    }

    public function get ctrl () :RoomSubControlServer
    {
        return _ctrl;
    }

    /** All the players in this Room. */
    public function get players () :Dictionary
    {
        return _players;
    }

    protected function onPlayerLeft (event :AVRGameRoomEvent) :void
    {
        setMode(int(event.value), null);
    }

    protected function getCanvas (player :Player) :Canvas
    {
        var modes :Dictionary = Dictionary(_ctrl.props.get(Codes.PLAYER_MODES));
        if (modes == null) {
            throw new Error("Modes dictionary not found.");
        }

        var canvas :Canvas = Canvas(_canvases[modes[player.ctrl.getPlayerId()]]);
        if (canvas == null) {
            throw new Error("No valid mode found for player.");
        }

        return canvas;
    }

//    protected function onRoomElementChanged (event :ElementChangedEvent) :void
//    {
//        // Listen for mode switches to notify each canvas involved
//        if (event.name == Codes.PLAYER_MODES) {
//            var playerId :int = event.key;
//            if (event.oldValue != null) {
//                _canvases[int(event.oldValue)].playerDidClose(playerId);
//            }
//            if (event.newValue != null) {
//                _canvases[int(event.newValue)].playerDidOpen(playerId);
//            }
//        }
//    }
    public function setMode (playerId :int, newMode :Object) :void
    {
        var modes :Dictionary = Dictionary(_ctrl.props.get(Codes.PLAYER_MODES));

        if (modes != null && playerId in modes) {
            var oldMode :int = int(modes[playerId]);
            Canvas(_canvases[oldMode]).playerDidClose(playerId);
        }

        if (newMode != null) {
            Canvas(_canvases[newMode]).playerDidOpen(playerId);
        }

        _ctrl.props.setIn(Codes.PLAYER_MODES, playerId, newMode, true);
    }

    public function changeMode (player :Player, mode :int) :void
    {
        setMode(player.ctrl.getPlayerId(), mode);
    }

    public function sendStroke (player :Player, strokeBytes :ByteArray) :void
    {
        getCanvas(player).sendStroke(player, strokeBytes);
    }

    public function sendStrokeList (player :Player, list :Array) :void
    {
        _ctrl.doBatch(getCanvas(player).sendStrokeList, player, list);
    }

    public function removeStrokes (player :Player, strokeIds :Array) :void
    {
        _ctrl.doBatch(getCanvas(player).removeStrokes, player, strokeIds);
    }

    public function clearCanvas (player :Player) :void
    {
        getCanvas(player).clearCanvas(player);
    }

    public function pictionaryPass (player :Player) :void
    {
        _pictionary.pass(player);
    }

    protected var _ctrl :RoomSubControlServer;
    protected var _players :Dictionary = new Dictionary(); // playerId -> Player

    protected var _canvases :Array = []; // of Canvas
    protected var _pictionary :PictionaryCanvas;
}

}
