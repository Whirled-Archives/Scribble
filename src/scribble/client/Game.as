package scribble.client {

import flash.display.Sprite;
import flash.geom.Rectangle;

import com.threerings.util.Log;

import com.whirled.EntityControl;
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
        return ctrl.room.getOccupantName(playerId);
    }

    public static function canLock () :Boolean
    {
        return ctrl.room.canManageRoom() || Codes.isAdmin(ctrl.player.getPlayerId());
    }

    public static function isToolbenchHere () :Boolean
    {
        for each (var furni :String in ctrl.room.getEntityIds(EntityControl.TYPE_FURNI)) {
            if (ctrl.room.getEntityProperty(Codes.PUBLIC_TOOLBENCH, furni) === true) {
                return true;
            }
        }
        return false;
    }

    public function Game ()
    {
        ctrl = new AVRGameControl(this);
        if (!ctrl.isConnected()) {
            log.error("Not connected. Bailing!");
            return;
        }

        log.info("Starting Scribble", "compiled", BuildConfig.WHEN, "debug", BuildConfig.DEBUG);

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
        var bounds :Rectangle = ctrl.local.getPaintableArea();

        if (bounds != null) {
            ToolTipManager.instance.bounds = bounds;
        }
    }
}

}
