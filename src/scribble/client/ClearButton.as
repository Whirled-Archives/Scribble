package scribble.client {

import flash.display.Bitmap;
import flash.events.MouseEvent;

import com.threerings.util.Command;

import aduros.display.ImageButton;

// TODO: This probably doesn't need its own class anymore
public class ClearButton extends ImageButton
{
    public function ClearButton ()
    {
        super(Bitmap(new ICON()), Messages.en.xlate("t_clear"));
        Command.bind(this, MouseEvent.CLICK, ScribbleController.CLEAR_CANVAS);
    }

    [Embed(source="../../../res/clear.png")]
    protected static const ICON :Class;
}

}
