package scribble.client {

import flash.utils.ByteArray;

import com.threerings.util.Controller;
import com.threerings.util.StringUtil;
import com.threerings.util.ValueEvent;

import aduros.net.REMOTE;
import aduros.net.RemoteProvider;
import aduros.net.RemoteProxy;
import aduros.util.F;

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
        _roomService.toggleLock();
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

    protected var _roomService :RemoteProxy;
    protected var _gameService :RemoteProxy;
}

}
