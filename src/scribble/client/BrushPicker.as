package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;

import mx.utils.ColorUtil;

import com.gskinner.motion.GTween;

import com.threerings.util.Command;
import com.threerings.util.ValueEvent;

import scribble.data.Codes;

public class BrushPicker extends Sprite
{
    public static const BRUSH_CHANGED :String = "BrushChanged";

    public static const COLORS :Array = [ -1, 0, 48, 3, 60, 12, 36, 51, 42 ];

    public function BrushPicker ()
    {
        // Just force a height
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, 1, 40);
        graphics.endFill();

        createUI();
    }

    protected function createUI () :void
    {
        for (var ii :int = 0; ii < COLORS.length; ++ii) {
            var brushId :int = COLORS[ii] as int;
            var button :Sprite = new Sprite();

            if (brushId < 0) {
                button.addChild(new ICON_ERASER());
            } else {
                var color :int = GraphicsUtil.getColor(brushId);
                button.graphics.beginFill(color);
                button.graphics.lineStyle(1, ColorUtil.adjustBrightness(color, 0x33));
                button.graphics.drawRect(0, 0, 24, 24);
                button.graphics.endFill();
            }

            button.x = ii*24;
            button.y = _cursor.height-5;
            Command.bind(button, MouseEvent.CLICK, setColor, brushId);

            addChild(button);
        }

        addEventListener(BRUSH_CHANGED, function (event :ValueEvent) :void {
            var colorId :int = event.value < 0 ? -1 : (event.value as int) & 63;
            var toX :Number = COLORS.indexOf(colorId)*24 + 24/2 - _cursor.width/2;
            new GTween(_cursor, 0.2, {x: toX});
        });

        addChild(_cursor);
    }

    protected function setColor (colorId :int) :void
    {
        _colorId = colorId;
        if (_colorId < 0) {
            setBrush(-(_widthId+1));
        } else {
            setBrush(_widthId + _colorId);
        }
    }

    protected function setWidth (width :int) :void // width is [0..3]
    {
        _widthId = width<<6;
        setColor(_colorId);
    }

    public function reset () :void
    {
        // Reset to black, default width
        _widthId = 1<<6;
        setColor(0);
    }

    protected function setBrush (brushId :int) :void
    {
        dispatchEvent(new ValueEvent(BRUSH_CHANGED, brushId));
    }

    [Embed(source="../../../res/arrow_down.png")]
    protected static const ICON_CURSOR :Class;
    protected var _cursor :Bitmap = new ICON_CURSOR();

    protected var _colorId :int;
    protected var _widthId :int;

    [Embed(source="../../../res/eraser.png")]
    protected static const ICON_ERASER :Class;
}

}
