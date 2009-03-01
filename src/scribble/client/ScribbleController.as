package scribble.client {

import flash.utils.ByteArray;

import com.threerings.util.Controller;
import com.threerings.util.ValueEvent;

import aduros.net.RemoteCaller;

import scribble.data.Stroke;

public class ScribbleController extends Controller
{
    // Controller commands
    public static const CLEAR_CANVAS :String = "ClearCanvas";
    public static const SEND_STROKE :String = "SendStroke";
    public static const REMOVE_STROKES :String = "RemoveStrokes";
    public static const CHANGE_MODE :String = "ChangeMode";

    public static const BROADCAST :String = "Broadcast";

    public var panel :ScribblePanel;

    public function ScribbleController ()
    {
        _roomService = new RemoteCaller(Game.ctrl.agent, "room");
        _gameService = new RemoteCaller(Game.ctrl.agent, "game");

        panel = new ScribblePanel();
        setControlledPanel(panel);
    }

    public function handleClearCanvas () :void
    {
        _roomService.clearCanvas();
    }

//    public function handleSendStroke (stroke :Stroke) :void
//    {
//        Game.ctrl.agent.sendMessage("sendStroke", stroke.toBytes());
//        //panel.debugAddStroke(stroke);
//    }

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

    public function handleBroadcast (message :String) :void
    {
        _gameService.sendBroadcast(message);
    }

    protected var _roomService :RemoteCaller;
    protected var _gameService :RemoteCaller;
}

}
