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
        parent.removeChild(this);
    }
}

}
