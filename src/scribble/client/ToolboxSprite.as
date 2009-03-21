package scribble.client {

import flash.display.Sprite;

public class ToolboxSprite extends Sprite
{
    public var picker :BrushPicker;
    public var undo :UndoSprite;

    public function ToolboxSprite (canvas :CanvasSprite)
    {
        picker = new BrushPicker();
        undo = new UndoSprite(canvas);

        addChild(picker);

        var clearButton :ClearButton = new ClearButton();
        clearButton.x = width+16;
        clearButton.y = height/2 - clearButton.height/2;
        addChild(clearButton);

        undo.x = width+4;
        undo.y = height/2 - undo.height/2;
        addChild(undo);
    }

    public function reset () :void
    {
        picker.setBrush(1);
    }
}

}
