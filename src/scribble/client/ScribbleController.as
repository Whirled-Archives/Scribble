package scribble.client {

import flash.utils.ByteArray;

import com.threerings.util.Controller;
import com.threerings.util.StringUtil;
import com.threerings.util.ValueEvent;

import com.whirled.avrg.AVRGamePlayerEvent;

import aduros.net.REMOTE;
import aduros.net.RemoteProvider;
import aduros.net.RemoteProxy;
import aduros.util.F;

import scribble.data.Codes;
import scribble.data.Stroke;

public class ScribbleController extends Controller
{
    // Controller commands
    public static const CLEAR_CANVAS :String = "ClearCanvas";
    public static const SEND_STROKE :String = "SendStroke";
    public static const REMOVE_STROKES :String = "RemoveStrokes";
    public static const CHANGE_MODE :String = "ChangeMode";
    public static const BROADCAST :String = "Broadcast";
    public static const PICTIONARY_PASS :String = "PictionaryPass";
    public static const PICTIONARY_GUESS :String = "PictionaryGuess";
    public static const TOGGLE_LOCK :String = "ToggleLock";
    public static const LOCATE_PEERS :String = "LocatePeers";
    public static const QUIT :String = "Quit";
    public static const INVITE :String = "Invite";

    public var panel :ScribblePanel;

    public function ScribbleController ()
    {
        _roomService = new RemoteProxy(Game.ctrl.agent, "room");
        _gameService = new RemoteProxy(Game.ctrl.agent, "game");

        panel = new ScribblePanel();
        setControlledPanel(panel);

        new RemoteProvider(Game.ctrl.player, "mode", panel.getModeSprite);
        new RemoteProvider(Game.ctrl.player, "player", F.konst(this));
        new RemoteProvider(Game.ctrl.game, "game", F.konst(this));

        // The room name doesn't exist on the server, and we need it.
        // Therefore jump through a flaming hoop to get it.
        Game.ctrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, function (... _) :void {
            if (Game.ctrl.room.getPlayerIds().length == 1) {
                Game.log.info("Sending updated room name to server");
                _roomService.updateName(Game.ctrl.room.getRoomName());
            }
        });
    }

    public function handleClearCanvas () :void
    {
        _roomService.clearCanvas();
    }

    public function handleSendStroke (... strokes) :void
    {
        if (strokes.length == 1) {
            _roomService.sendStroke(strokes[0].toBytes());
        } else {
            _roomService.sendStrokeList(
                strokes.map(function (stroke :Stroke, ... _) :ByteArray {
                    return stroke.toBytes();
                }));
        }
    }

    public function handleRemoveStrokes (... strokeIds) :void
    {
        _roomService.removeStrokes(strokeIds);
    }

    public function handleChangeMode (mode :int) :void
    {
        _roomService.changeMode(mode);
    }

    public function handleBroadcast (text :String) :void
    {
        _gameService.sendBroadcast(text);
    }

    public function handlePictionaryPass () :void
    {
        _roomService.pictionaryPass();
    }

    public function handlePictionaryGuess (guess :String) :void
    {
        if (StringUtil.isBlank(guess)) {
            Game.log.info("Refusing to send blank guess", "guess", guess);
        } else {
            _roomService.pictionaryGuess(guess);
        }
    }

    public function handleToggleLock () :void
    {
        if (Game.canLock()) {
            _roomService.toggleLock();
        } else {
            Game.log.error("Ignored request to lock unowned room.");
        }
    }

    public function handleLocatePeers (mode :int) :void
    {
        _gameService.locatePeers(mode);
    }

    public function handleQuit () :void
    {
        // TODO: Put up an ARE YOU SURE? dialog
        Game.ctrl.local.feedback(Messages.en.xlate("m_bye"));
        Game.ctrl.player.deactivateGame();
    }

    public function handleInvite () :void
    {
        Game.ctrl.local.showInvitePage(Messages.en.xlate("m_invite"));
    }

    REMOTE function broadcast (message :Array) :void
    {
        Game.ctrl.local.feedback(Messages.en.xlate(message));
    }

    REMOTE function feed (message :Array) :void
    {
        // TODO: Put into a feed ticker sprite
        Game.ctrl.local.feedback("Feed: " + Messages.en.xlate(message));
    }

    REMOTE function peersLocated (result :Array) :void
    {
        for (var mode :int = 0; mode < 2; ++mode) {
            Game.ctrl.local.feedback(Messages.en.xlate("m_locatedHeader",
                Messages.en.xlate("l_mode"+mode)));

            if (result[mode].length > 0) {
                for each (var room :Array in result[mode]) {
                    var roomId :int = room[0];
                    var name :String = room[1];
                    var pop :int = room[2];
                    Game.ctrl.local.feedback(Messages.en.xlate("m_locatedRoom",
                        roomId, name, pop));
                }
            } else {
                Game.ctrl.local.feedback(Messages.en.xlate("m_locatedNone",
                    Messages.en.xlate("l_mode"+mode)));
            }
        }
    }

    protected var _roomService :RemoteProxy;
    protected var _gameService :RemoteProxy;
}

}
