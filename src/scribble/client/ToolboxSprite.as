package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.Command;

import aduros.display.ImageButton;

import scribble.data.Codes;

public class ToolboxSprite extends Sprite
{
    public var picker :BrushPicker;
    public var undo :UndoSprite;

    public function ToolboxSprite (canvas :CanvasSprite)
    {
        picker = Codes.hasToolboxUpgrade(Game.ctrl.player) || Game.isToolbenchHere() ?
            new DeluxeBrushPicker() : new BrushPicker();
        undo = new UndoSprite(canvas);

        addChild(picker);

        var clearButton :ImageButton = new ImageButton(Bitmap(new ICON_CLEAR()),
            Messages.en.xlate("t_clear"));
        Command.bind(clearButton, MouseEvent.CLICK, ScribbleController.CLEAR_CANVAS);
        GraphicsUtil.throttleClicks(clearButton);
        clearButton.x = width+16;
        clearButton.y = height/2 - clearButton.height/2;
        addChild(clearButton);

        undo.x = width+4;
        undo.y = height/2 - undo.height/2;
        addChild(undo);
    }

    public function reset () :void
    {
        picker.reset();
    }

    [Embed(source="../../../res/clear.png")]
    protected static const ICON_CLEAR :Class;
}

}
