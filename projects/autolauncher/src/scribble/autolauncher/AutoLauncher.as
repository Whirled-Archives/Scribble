package scribble.autolauncher {

import flash.display.Sprite;

import com.whirled.*;

/**
 * Its only purpose is to automatically launch the game when joining the room.
 * Unfortunately, it tries to pop up a new window in embeds.
 */
public class AutoLauncher extends Sprite
{
    public function AutoLauncher ()
    {
        _ctrl = new ToyControl(this);

        if (_ctrl.getEnvironment() == EntityControl.ENV_ROOM) {
            _ctrl.showPage("world-game_j_1994_878");
        }
    }

    protected var _ctrl :ToyControl;
}

}
