package scribble.server {

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import com.threerings.util.Log;

import com.whirled.ServerObject;
import com.whirled.avrg.*;
import com.whirled.net.*;

import aduros.i18n.MessageUtil;
import aduros.net.RemoteProvider;
import aduros.util.F;

import scribble.data.Codes;

public class Server extends ServerObject
{
    public static const log :Log = Log.getLog(Server);

    public function Server ()
    {
        log.info("Scribble " + BuildConfig.WHEN +
            ". This could be the beginning of a beautiful game", "debug", BuildConfig.DEBUG);

        _ctrl = new AVRServerGameControl(this);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, onPlayerJoin);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, onPlayerQuit);

        // Load up the pictionary word list right off the bat
        _ctrl.game.loadLevelPackData("wordlist", PictionaryCanvas.createWordList,
            F.curry(log.error, "Couldn't load word list!"));

        _gameManager = new GameManager(this, _ctrl.game);

        new RemoteProvider(_ctrl.game, "game", F.konst(_gameManager));
        new RemoteProvider(_ctrl.game, "room", function (senderId :int) :Object {
            return getPlayer(senderId).room;
        });
    }

    public function getRoom (roomId :int) :RoomManager
    {
        return _rooms[roomId];
    }

    public function getPlayer (playerId :int) :Player
    {
        return _players[playerId];
    }

    public function getRooms () :Object
    {
        return _rooms;
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

        var firstRoom :Boolean = (player.room == null);

        player.room = room;
        if (playerId in room.players) {
            log.warning("Player was already in entered room?", "playerId", playerId, "roomId", roomId);
        }
        room.players[playerId] = player;

        if (firstRoom) {
//            _gameManager.feed("m_joined", player.getName());
            player.stats.submit("boughtToolbox", Codes.hasToolboxUpgrade(player.ctrl));
        }
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
