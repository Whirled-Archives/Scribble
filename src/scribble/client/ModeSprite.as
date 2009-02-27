package scribble.client {

import flash.display.Sprite;

public class ModeSprite extends Sprite
{
    public function didEnter () :void
    {
        // Stop/reverse any didLeave transitions and do other setup
    }

    public function didLeave () :void
    {
        // Uh, for some reason GTween is called its complete handlers when the sprite is
        // REMOVED_FROM_STAGE, so this null check is necessary
        if (parent != null) {
            parent.removeChild(this);
        }
    }
}

}
