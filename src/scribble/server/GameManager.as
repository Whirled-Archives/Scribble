package scribble.server {

import com.whirled.avrg.*;

import aduros.i18n.MessageUtil;
import aduros.net.REMOTE;
import aduros.net.RemoteCaller;

import scribble.data.Codes;

public class GameManager
{
    public function GameManager (server :Server, ctrl :GameSubControlServer)
    {
        _server = server;
        _ctrl = ctrl;

        _gameReceiver = new RemoteCaller(ctrl, "game");
    }

    protected function requireAdmin (playerId :int) :void
        // throws Error
    {
        if (!Codes.isAdmin(playerId)) {
            throw new Error("Admin permission denied.");
        }
    }

    REMOTE function sendBroadcast (playerId :int, text :String) :void
    {
        requireAdmin(playerId);

        var player :Player = _server.getPlayer(playerId);
        
        _gameReceiver.apply("broadcast", MessageUtil.pack("m_broadcast", player.getName(), text));
    }

    REMOTE function locatePeers (playerId :int, mode :int) :void
    {
        var result :Array = []; // [ [ [56431, "Bob's room", 4], ... ], [ ... ] ]

        for (var mode :int = 0; mode < 2; ++mode) {
            var rooms :Array = []; // of loose Object
            for each (var room :RoomManager in _server.getRooms()) {
                var pop :int = room.playersInMode(mode);
                if (pop > 0) {
                    rooms.push({
                        roomId: room.ctrl.getRoomId(),
                        name: room.name,
                        pop: pop
                    });
                }
            }

            var top5 :Array = rooms.sortOn("pop", Array.NUMERIC | Array.DESCENDING).splice(0, 4);

            var modeResult :Array = [];
            for each (var o :Object in top5) {
                Server.log.info("Got Top5 room", "mode", mode, "roomId", o.roomId, "name", o.name, "pop", o.pop);
                modeResult.push([ o.roomId, o.name, o.pop ]);
            }
            result[mode] = modeResult;
        }

        // Respond to client request
        _server.getPlayer(playerId).playerReceiver.apply("peersLocated", result);
    }

    public function feed (key :String, ... msg) :void
    {
        _gameReceiver.apply("feed", MessageUtil.pack(key, msg));
    }

    protected var _gameReceiver :RemoteCaller;

    protected var _server :Server;
    protected var _ctrl :GameSubControlServer;
}

}
