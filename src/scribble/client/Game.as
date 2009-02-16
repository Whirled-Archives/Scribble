package scribble.client {

import flash.display.Sprite;

import com.whirled.avrg.AVRGameControl;

public class Game extends Sprite
{
    public static var ctrl :AVRGameControl;

    public static function getName (playerId :int) :String
    {
        return ctrl.room.getAvatarInfo(playerId).name;
    }

    public function Game ()
    {
        ctrl = new AVRGameControl(this);

        if (!ctrl.isConnected()) {
//            var wedge :Wedge = new Wedge(100);
//            wedge.filters = [ new DropShadowFilter() ];
//            wedge.arc = 360;
//            var tween :GTween = new GTween(wedge, 2, {arc: 0}, {repeat: -1});
//            addChild(wedge);
            return;
        }

        var controller :ScribbleController = new ScribbleController();
        addChild(controller.panel);
    }
}

}
