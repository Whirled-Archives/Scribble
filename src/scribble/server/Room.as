package scribble.server {

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Set;

import com.whirled.avrg.*;
import com.whirled.net.*;

import aduros.net.REMOTE;

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

        _canvases.push(new BackdropCanvas(0, this));
        _canvases.push(_pictionary);
    }

    public function get ctrl () :RoomSubControlServer
    {
        return _ctrl;
    }

    /** All the players in this Room. */
    public function get players () :Dictionary
    {
        return _players; // TODO: Necessary?
    }

    protected function onPlayerLeft (event :AVRGameRoomEvent) :void
    {
        setMode(int(event.value), null);
    }

    protected function getCanvas (playerId :int) :Canvas
    {
        var modes :Dictionary = Dictionary(_ctrl.props.get(Codes.PLAYER_MODES));
        if (modes == null) {
            throw new Error("Modes dictionary not found.");
        }

        var canvas :Canvas = Canvas(_canvases[modes[playerId]]);
        if (canvas == null) {
            throw new Error("No valid mode found for player.");
        }

        return canvas;
    }

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

    REMOTE function changeMode (playerId :int, mode :int) :void
    {
        _ctrl.doBatch(setMode, playerId, mode);
    }

    REMOTE function sendStroke (playerId :int, strokeBytes :ByteArray) :void
    {
        _ctrl.doBatch(getCanvas(playerId).sendStroke, playerId, strokeBytes);
    }

    REMOTE function sendStrokeList (playerId :int, list :Array) :void
    {
        _ctrl.doBatch(getCanvas(playerId).sendStrokeList, playerId, list);
    }

    REMOTE function removeStrokes (playerId :int, strokeIds :Array) :void
    {
        _ctrl.doBatch(getCanvas(playerId).removeStrokes, playerId, strokeIds);
    }

    REMOTE function clearCanvas (playerId :int) :void
    {
        _ctrl.doBatch(getCanvas(playerId).clearCanvas, playerId);
    }

    REMOTE function pictionaryPass (playerId :int) :void
    {
        _ctrl.doBatch(_pictionary.pass, playerId);
    }

    protected var _ctrl :RoomSubControlServer;
    protected var _players :Dictionary = new Dictionary(); // playerId -> Player

    protected var _canvases :Array = []; // of Canvas
    protected var _pictionary :PictionaryCanvas;
}

}
