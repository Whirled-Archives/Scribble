package scribble.client {

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

import com.gskinner.motion.GTween;
import com.gskinner.motion.MultiTween; // TODO: Upgrade to latest GTween and use timelines

import com.whirled.avrg.MobSubControlClient;
import com.whirled.avrg.AVRGameControlEvent;

import scribble.data.Codes;

public class BackdropMode extends ModeSprite
{
    public function BackdropMode ()
    {
        // One time setting. These bounds aren't updated when the backdrop changes
        // Consider just making the bounds [MAX_INT, MAX_INT]?
        var bounds :Array = Game.ctrl.local.getRoomBounds();
        _canvas = new CanvasSprite(Codes.CANVAS_PREFIXES[Codes.CANVAS_ROOM],
            bounds[0], bounds[1], this);

        _toolbox = _canvas.createToolbox();
        addChild(_toolbox);

        onResize();
        _toolbox.y += _toolbox.height;

        _slideIn = new GTween(_toolbox, 2, {y: _toolbox.y-_toolbox.height}, {autoPlay: false});

        _fadeOut = new GTween(null, 2, null, {autoPlay: false});
        _fadeOut.addEventListener(Event.COMPLETE, onFadeComplete);
        new MultiTween([this, _canvas], {alpha: 0}, _fadeOut);

        addEventListener(Event.ADDED_TO_STAGE, function (... _) :void {
            var mob :MobSubControlClient = Game.ctrl.room.getMobSubControl(Codes.MOB_FOREGROUND);
            if (mob != null) {
                Sprite(mob.getMobSprite()).addChild(_canvas);
                mob.setHotSpot(_canvas.width/2, _canvas.height, 0);
            } else {
                Game.log.warning("Where's the mob?");
            }

            _canvas.init(true);
            Game.ctrl.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED, onResize);
        });

        addEventListener(Event.REMOVED_FROM_STAGE, function (... _) :void {
            var mob :MobSubControlClient = Game.ctrl.room.getMobSubControl(Codes.MOB_FOREGROUND);
            if (mob != null) {
                var mobSprite :Sprite = Sprite(mob.getMobSprite());
                if (mobSprite.contains(_canvas)) { // These 2 checks can fail when transitioning to a new room
                    mobSprite.removeChild(_canvas);
                }
            }

            Game.ctrl.local.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, onResize);
        });
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
    }

    protected function onResize (... _) :void
    {
        var screen :Rectangle = Game.ctrl.local.getPaintableArea();
        if (screen != null) {
            // Bind to bottom right
            _toolbox.x = screen.width-_toolbox.width;
            _toolbox.y = screen.height-_toolbox.height;
        }
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
