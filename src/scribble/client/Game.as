package scribble.client {

import flash.display.Sprite;

import com.threerings.util.Log;

import com.whirled.avrg.AVRGameControl;

public class Game extends Sprite
{
    public static var ctrl :AVRGameControl;
    public static const log :Log = Log.getLog(Game);

    public static function getName (playerId :int) :String
    {
        return ctrl.room.getAvatarInfo(playerId).name;
    }

    public function Game ()
    {
        var msg :String = "Scribble, compiled at " + BuildConfig.WHEN;
        log.info(msg, "debug", BuildConfig.DEBUG);

        ctrl = new AVRGameControl(this);
        if (!ctrl.isConnected()) {
            return;
        }

        if (BuildConfig.DEBUG) {
            ctrl.local.feedback(msg);
        }

        var controller :ScribbleController = new ScribbleController();
        addChild(controller.panel);
    }
}

}
