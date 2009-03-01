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

        _gameService = new RemoteCaller(ctrl, "game");
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
        
        _gameService.apply("broadcast", MessageUtil.pack("broadcast", player.getName(), text));
    }

    public function feed (key :String, ... msg) :void
    {
        _gameService.apply("feed", MessageUtil.pack(key, msg));
    }

    protected var _gameService :RemoteCaller;

    protected var _server :Server;
    protected var _ctrl :GameSubControlServer;
}

}
