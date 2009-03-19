package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;

import com.gskinner.motion.GTween;

import com.threerings.util.Command;
import com.threerings.util.ValueEvent;

import scribble.data.Codes;

public class BrushPicker extends Sprite
{
    public static const BRUSH_CHANGED :String = "BrushChanged";

    public function BrushPicker ()
    {
        for (var brushId :int = 0; brushId < Codes.BRUSH_COLORS.length; ++brushId) {
            var button :Sprite = new Sprite();

            if (brushId == 0) {
                button.addChild(new ICON_ERASER());
            } else {
                var color :int = Codes.BRUSH_COLORS[brushId];
                button.graphics.beginFill(color);
                button.graphics.drawRect(0, 0, 24, 24);
                button.graphics.endFill();
            }

            button.x = brushId*24;
            button.y = _cursor.height-5;
            Command.bind(button, MouseEvent.CLICK, setBrush, brushId);

            addChild(button);
        }

//        _cursor.y = -_cursor.height;
        addChild(_cursor);
    }

    public function setBrush (brushId :int) :void
    {
        var toX :Number = brushId*24 + 24/2 - _cursor.width/2
        new GTween(_cursor, 0.2, {x: toX});

        dispatchEvent(new ValueEvent(BRUSH_CHANGED, brushId));
    }

    [Embed(source="../../../res/arrow_down.png")]
    protected static const ICON_CURSOR :Class;
    protected var _cursor :Bitmap = new ICON_CURSOR();

    [Embed(source="../../../res/eraser.png")]
    protected static const ICON_ERASER :Class;
}

}
