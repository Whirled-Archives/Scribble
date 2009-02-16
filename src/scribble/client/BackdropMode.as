package scribble.client {

import scribble.data.Codes;

public class BackdropMode extends ModeSprite
{
    public function BackdropMode ()
    {
        _canvas = new CanvasSprite(Codes.CANVAS_PREFIXES[Codes.CANVAS_ROOM]);
        addChild(_canvas);
    }

    public override function didEnter () :void
    {
        _canvas.init(true);
    }

    protected var _canvas :CanvasSprite;
}

}
