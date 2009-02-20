package scribble.client {

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

import com.gskinner.motion.GTween;

import scribble.data.Codes;

public class BackdropMode extends ModeSprite
{
    public function BackdropMode ()
    {
        _canvas = new CanvasSprite(Codes.CANVAS_PREFIXES[Codes.CANVAS_ROOM]);
        addChild(_canvas);

        _toolbox = _canvas.createToolbox();
        
        var screen :Rectangle = Game.ctrl.local.getPaintableArea();

        _toolbox.x = screen.width-_toolbox.width;
        _toolbox.y = screen.height;
        addChild(_toolbox);

        _slideIn = new GTween(_toolbox, 2, {y: screen.height-_toolbox.height}, {autoPlay: false});
        _fadeOut = new GTween(this, 2, {alpha: 0}, {autoPlay: false});
        _fadeOut.addEventListener(Event.COMPLETE, onFadeComplete);
    }

    protected function onFadeComplete (event :Event) :void
    {
        if (alpha == 0) {
            super.didLeave();
        }
    }

    override public function didEnter () :void
    {
        if (_transition == 0) {
            _slideIn.play();
            _transition = 1;
        } else {
            GraphicsUtil.flip(_slideIn);
            GraphicsUtil.flip(_fadeOut);
            _transition = 2;
        }

        _canvas.init(true);
    }

    override public function didLeave () :void
    {
        GraphicsUtil.flip(_slideIn);

        if (_transition == 1) {
            _fadeOut.play();
        } else {
            GraphicsUtil.flip(_fadeOut);
        }
        _transition = 2;
    }

    protected var _canvas :CanvasSprite;
    protected var _toolbox :Sprite;

    // Transitions
    protected var _slideIn :GTween;
    protected var _fadeOut :GTween;
    protected var _transition :int = 0;
}

}
