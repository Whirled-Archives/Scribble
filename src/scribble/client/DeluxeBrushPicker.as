package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;

import mx.utils.ColorUtil;

import com.gskinner.motion.GTween;

import com.threerings.util.Command;
import com.threerings.util.ValueEvent;

import scribble.data.Codes;

public class DeluxeBrushPicker extends BrushPicker
{
    override protected function createUI () :void
    {
        var eraser :Sprite = new Sprite();
        eraser.addChild(new ICON_ERASER());
        eraser.y = 4;
        Command.bind(eraser, MouseEvent.CLICK, setColor, -1);
        addChild(eraser);

        for (var colorId :int = 0; colorId < 64; ++colorId) {
            var color :int = GraphicsUtil.getColor(colorId);
            var button :Sprite = new Sprite();
            button.x = 8*(colorId%16) + eraser.y + eraser.width + 2;
            button.y = 8*Math.floor(colorId/16) + 4;
            Command.bind(button, MouseEvent.CLICK, setColor, colorId);

            button.graphics.beginFill(color);
            button.graphics.drawRect(0, 0, 8, 8);
            button.graphics.endFill();

            addChild(button);
        }

        for (var widthId :int = 0; widthId < 4; ++widthId) {
            button = new Sprite();
            button.x = this.width + 24*widthId;
            button.y = 8;
            Command.bind(button, MouseEvent.CLICK, setWidth, widthId);

            _widths.push(button);
            addChild(button);
        }
        renderWidths(0);

        addEventListener(BRUSH_CHANGED, function (event :ValueEvent) :void {
            var brushId :int = event.value as int;
            renderWidths(GraphicsUtil.getColor(brushId));

            var toX :Number = _widths[0].x + GraphicsUtil.getWidth(brushId)*24 + 24/2 - _cursor.width/2;
            new GTween(_cursor, 0.2, {x: toX});
        });

        addChild(_cursor);
    }

    protected function renderWidths (color :int) :void
    {
        for (var ii :int = 0; ii < _widths.length; ++ii) {
            var sprite :Sprite = _widths[ii];
            sprite.graphics.clear();
            sprite.graphics.beginFill(0, 0);
            sprite.graphics.drawRect(0, 0, 24, 24);
            sprite.graphics.beginFill(color);
            sprite.graphics.lineStyle(1, ColorUtil.adjustBrightness(color, 0x66));
            sprite.graphics.drawCircle(12, 12, 0.5*Math.pow(2, ii+1)+1);
            sprite.graphics.endFill();
        }
    }

    protected var _widths :Array = []; // of Sprite
}

}
