package scribble.server {

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.threerings.util.Log;

import com.whirled.ServerObject;
import com.whirled.avrg.*;
import com.whirled.net.*;

import aduros.i18n.MessageUtil;
import aduros.net.RemoteProvider;

import scribble.data.Codes;

public class Server extends ServerObject
{
    public static const log :Log = Log.getLog(Server);

    public function Server ()
    {
        _ctrl = new AVRServerGameControl(this);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, onPlayerJoin);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, onPlayerQuit);

        _gameManager = new GameManager(this, _ctrl.game);

        new RemoteProvider(_ctrl.game, "game", function (senderId :int) :Object {
            return _gameManager;
        });
        new RemoteProvider(_ctrl.game, "room", function (senderId :int) :Object {
            return getPlayer(senderId).room;
        });

        log.info("Scribble started. This could be the beginning of a beautiful game");
    }

    public function getRoom (roomId :int) :RoomManager
    {
        return _rooms[roomId];
    }

    public function getPlayer (playerId :int) :Player
    {
        return _players[playerId];
    }

    protected function onPlayerJoin (event :AVRGameControlEvent) :void
    {
        var playerId :int = int(event.value);

        if (playerId in _players) {
            log.warning("Player was already registered", "playerId", playerId);
        }

        var player :Player = new Player(_ctrl.getPlayer(playerId));

        player.ctrl.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, onRoomEntered);
        player.ctrl.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, onRoomLeft);

        _players[playerId] = player;
    }

    protected function onPlayerQuit (event :AVRGameControlEvent) :void
    {
        var playerId :int = int(event.value);
        var player :Player = getPlayer(playerId);

        if (player != null) {
            delete _players[playerId];
        } else {
            log.warning("Trying to deregister missing player", "playerId", playerId);
        }

        // TODO: Remove listeners on player?
    }

    protected function onRoomEntered (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = int(event.value);

        var player :Player = getPlayer(playerId);
        var room :RoomManager = getRoom(roomId);

        if (room == null) {
            room = new RoomManager(_ctrl.getRoom(roomId));
            room.ctrl.addEventListener(AVRGameRoomEvent.ROOM_UNLOADED, onRoomUnloaded);
            _rooms[roomId] = room;
        }

//        room.setMode(playerId, Codes.CANVAS_ROOM); // TODO: Move this out?
//        room.ctrl.props.setIn(Codes.PLAYER_MODES, playerId, Codes.CANVAS_ROOM, true);

        player.room = room;
        if (playerId in room.players) {
            log.warning("Player was already in entered room?", "playerId", playerId, "roomId", roomId);
        }
        room.players[playerId] = player;
    }

    protected function onRoomUnloaded (event :AVRGameRoomEvent) :void
    {
        var roomId :int = event.roomId;

        if (roomId in _rooms) {
            delete _rooms[roomId];
        } else {
            log.warning("Tried to cleanly unload an unregistered room", "roomId", roomId);
        }
    }

    protected function onRoomLeft (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = int(event.value);

        var player :Player = getPlayer(playerId);
        var room :RoomManager = getRoom(roomId);

        if (room == null) {
            log.warning("Player tried to leave an unregistered room",
                "playerId", playerId, "roomId", roomId);
        } else if (!(playerId in room.players)) {
            log.warning("Player wasn't in left room?", "playerId", playerId, "roomId", roomId);
        } else {
            delete room.players[playerId];
        }
    }

    protected var _ctrl :AVRServerGameControl;

    protected var _gameManager :GameManager;

    protected var _players :Dictionary = new Dictionary(); // playerId -> Player
    protected var _rooms :Dictionary = new Dictionary(); // roomId -> RoomManager
}

}
