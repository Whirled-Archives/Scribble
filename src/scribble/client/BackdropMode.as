package scribble.client {

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

import com.gskinner.motion.GTween;
import com.gskinner.motion.MultiTween; // TODO: Upgrade to latest GTween and use timelines

import com.threerings.util.MethodQueue;

import com.whirled.avrg.*;

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
            Game.ctrl.room.addEventListener(AVRGameRoomEvent.MOB_CONTROL_AVAILABLE, onMobSpawned);
            onMobSpawned(); // It could already be available

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

            Game.ctrl.room.removeEventListener(AVRGameRoomEvent.MOB_CONTROL_AVAILABLE, onMobSpawned);
            Game.ctrl.local.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, onResize);
        });
    }

    protected function onFadeComplete (event :Event) :void
    {
        if (alpha == 0) {
            super.didLeave();
        }
    }

    protected function onMobSpawned (event :AVRGameRoomEvent = null) :void
    {
        var mob :MobSubControlClient = (event != null) ?
            MobSubControlClient(event.value) : Game.ctrl.room.getMobSubControl(Codes.MOB_FOREGROUND);
        if (mob != null) {
            // Whirled's internal MobSprite seems to wipe itself once too often when a new mob
            // is set up. This callLater is to avoid a race condition when canvas is added to the
            // mob, but is then wiped by Whirled.
            // TODO: Report this bug
            MethodQueue.callLater(function () :void {
                var sprite :Sprite = Sprite(mob.getMobSprite());
                sprite.addChild(_canvas);
                mob.setHotSpot(_canvas.width/2, _canvas.height, 0);
            });
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

    protected static var _canvas :CanvasSprite;
    protected var _toolbox :Sprite;

    // Transitions
    protected var _slideIn :GTween;
    protected var _fadeOut :GTween;
    protected var _transition :int = 0;
}

}
