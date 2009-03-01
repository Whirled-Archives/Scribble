package scribble.client {

import flash.display.Bitmap;
import flash.events.MouseEvent;

import com.threerings.util.Command;

import aduros.display.ImageButton;

public class ClearButton extends ImageButton
{
    public function ClearButton ()
    {
        super(Bitmap(new ICON()));
        Command.bind(this, MouseEvent.CLICK, ScribbleController.CLEAR_CANVAS);
    }

    [Embed(source="../../../res/clear.png")]
    protected static const ICON :Class;
}

}
