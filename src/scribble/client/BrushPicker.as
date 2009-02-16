package scribble.client {

import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.Command;
import com.threerings.util.ValueEvent;

import scribble.data.Codes;

public class BrushPicker extends Sprite
{
    public static const BRUSH_CHANGED :String = "BrushChanged";

    public function BrushPicker ()
    {
        //var cursor :Shape = new Sprite();
        for (var brushId :int = 0; brushId < Codes.BRUSH_COLORS.length; ++brushId) {
            var color :int = Codes.BRUSH_COLORS[brushId];
            var button :Sprite = new Sprite();

            button.graphics.beginFill(color);
            button.graphics.drawRect(0, 0, 24, 24);
            button.graphics.endFill();
            button.x = brushId*24;
            Command.bind(button, MouseEvent.CLICK, setBrush, brushId);

            addChild(button);
        }
    }

    public function setBrush (brushId :int) :void
    {
        dispatchEvent(new ValueEvent(BRUSH_CHANGED, brushId));
        // TODO: Animate cursor
    }
}

}
