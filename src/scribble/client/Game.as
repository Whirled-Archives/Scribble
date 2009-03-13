package scribble.client {

import flash.display.Sprite;

import com.threerings.util.Log;

import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;

import aduros.display.ToolTipManager;

import scribble.data.Codes;

public class Game extends Sprite
{
    public static var ctrl :AVRGameControl;
    public static const log :Log = Log.getLog(Game);

    public static function getName (playerId :int) :String
    {
        return ctrl.room.getAvatarInfo(playerId).name;
    }

    public static function canLock () :Boolean
    {
        return ctrl.room.canManageRoom() || Codes.isAdmin(ctrl.player.getPlayerId());
    }

    public function Game ()
    {
        ctrl = new AVRGameControl(this);
        if (!ctrl.isConnected()) {
            log.error("Not connected. Bailing!");
            return;
        }

        var msg :String = "Scribble, compiled at " + BuildConfig.WHEN;
        log.info(msg, "debug", BuildConfig.DEBUG);
        if (BuildConfig.DEBUG) {
            ctrl.local.feedback(msg);
        }

        // Set up the ToolTipManager
        ToolTipManager.instance.screen = this;
        ctrl.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED, function (... _) :void {
            updateToolTipBounds();
        });
        updateToolTipBounds();

        var controller :ScribbleController = new ScribbleController();
        addChild(controller.panel);
    }

    protected function updateToolTipBounds () :void
    {
        ToolTipManager.instance.bounds = ctrl.local.getPaintableArea();
    }
}

}
