package scribble.client {

import flash.utils.ByteArray;

import com.threerings.util.Controller;
import com.threerings.util.ValueEvent;

import scribble.data.Stroke;

public class ScribbleController extends Controller
{
    // Controller commands
    public static const CLEAR_CANVAS :String = "ClearCanvas";
    public static const SEND_STROKE :String = "SendStroke";
    public static const REMOVE_STROKES :String = "RemoveStrokes";
    public static const CHANGE_MODE :String = "ChangeMode";

    public var panel :ScribblePanel;

    public function ScribbleController ()
    {
        panel = new ScribblePanel();
        setControlledPanel(panel);
    }

    public function handleClearCanvas () :void
    {
        Game.ctrl.agent.sendMessage("clearCanvas");
    }

//    public function handleSendStroke (stroke :Stroke) :void
//    {
//        Game.ctrl.agent.sendMessage("sendStroke", stroke.toBytes());
//        //panel.debugAddStroke(stroke);
//    }

    public function handleSendStroke (... strokes) :void
    {
        if (strokes.length == 1) {
            Game.ctrl.agent.sendMessage("sendStroke", strokes[0].toBytes());
        } else {
            Game.ctrl.agent.sendMessage("sendStrokeList",
                strokes.map(function (stroke :Stroke, ... _) :ByteArray {
                    return stroke.toBytes();
                }));
        }
    }

    public function handleRemoveStrokes (... strokeIds) :void
    {
        Game.ctrl.agent.sendMessage("removeStrokes", strokeIds);
    }

    public function handleChangeMode (mode :int) :void
    {
        Game.ctrl.agent.sendMessage("changeMode", mode);
    }
}

}
