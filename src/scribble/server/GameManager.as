package scribble.server {

import com.whirled.avrg.*;

import aduros.i18n.MessageUtil;
import aduros.net.REMOTE;

import scribble.data.Codes;

public class GameManager
{
    public function GameManager (server :Server, ctrl :GameSubControlServer)
    {
        _server = server;
        _ctrl = ctrl;
    }

    protected function requireAdmin (playerId :int) :void
        // throws Error
    {
        if (!Codes.isAdmin(playerId)) {
            throw new Error("Admin permission denied.");
        }
    }

    REMOTE function sendBroadcast (playerId :int, message :String) :void
    {
        requireAdmin(playerId);

        var player :Player = _server.getPlayer(playerId);

        _ctrl.sendMessage(Codes.MESSAGE_BROADCAST,
            MessageUtil.pack("broadcast", player.getName(), message));
    }

    protected var _server :Server;
    protected var _ctrl :GameSubControlServer;
}

}
