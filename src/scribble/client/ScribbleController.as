package scribble.client {

import flash.utils.ByteArray;

import com.threerings.util.Controller;
import com.threerings.util.StringUtil;
import com.threerings.util.ValueEvent;

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

    public var panel :ScribblePanel;

    public function ScribbleController ()
    {
        _roomService = new RemoteProxy(Game.ctrl.agent, "room");
        _gameService = new RemoteProxy(Game.ctrl.agent, "game");

        panel = new ScribblePanel();
        setControlledPanel(panel);

        new RemoteProvider(Game.ctrl.player, "mode", panel.getModeSprite);
        new RemoteProvider(Game.ctrl.game, "game", F.konst(this));
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
        for each (var id :String in Game.ctrl.room.getEntityIds()) {
            var lockable :Object = Game.ctrl.room.getEntityProperty(Codes.PUBLIC_LOCKABLE, id);
            if (lockable is Boolean) {
                if (lockable) {
                    _roomService.toggleLock();
                } else {
                    Game.ctrl.local.feedback(Messages.en.xlate("lock_denied"));
                }
                return;
            }
        }

        Game.ctrl.local.feedback(Messages.en.xlate("lock_missing"));
    }

    public function handleLocatePeers (mode :int) :void
    {
        _gameService.locatePeers(mode);
    }

    REMOTE function broadcast (message :Array) :void
    {
        Game.ctrl.local.feedback("Broadcast: " + Messages.en.xlate(message));
    }

    REMOTE function feed (message :Array) :void
    {
        // TODO: Put into a feed ticker sprite
        Game.ctrl.local.feedback("Feed: " + Messages.en.xlate(message));
    }

    REMOTE function peersLocated (mode :int, roomId :int, population :int) :void
    {
        var modeName :String = Messages.en.xlate("l_mode"+mode);
        Game.ctrl.local.feedback((roomId > 0) ?
            Messages.en.xlate("m_locate_success", modeName, population, roomId) :
            Messages.en.xlate("m_locate_fail", modeName));
    }

    protected var _roomService :RemoteProxy;
    protected var _gameService :RemoteProxy;
}

}
