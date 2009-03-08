package scribble.client {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import com.gskinner.motion.GTween;
import com.gskinner.motion.MultiTween; // TODO: Upgrade to latest GTween and use timelines

import com.threerings.util.Command;
import com.threerings.util.MethodQueue;

import com.whirled.avrg.*;
import com.whirled.net.*;

import aduros.display.ImageButton;

import scribble.data.Codes;

public class BackdropMode extends ModeSprite
{
    public function BackdropMode ()
    {
        _prefix = Codes.CANVAS_PREFIXES[Codes.CANVAS_ROOM];

        // One time setting. These bounds aren't updated when the backdrop changes
        // Consider just making the bounds [MAX_INT, MAX_INT]?
        var bounds :Array = Game.ctrl.local.getRoomBounds();
        _canvas = new CanvasSprite(_prefix, bounds[0], bounds[1], this);

        _toolbox = _canvas.createToolbox();
        addChild(_toolbox);

        Command.bind(_lock, MouseEvent.CLICK, ScribbleController.TOGGLE_LOCK);
        addChild(_lock);

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
            Game.ctrl.room.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onRoomMessage);
            Game.ctrl.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED, onResize);

            Game.ctrl.room.props.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onRoomPropertyChanged);
            updateEnabled();
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
            Game.ctrl.room.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onRoomMessage);
            Game.ctrl.local.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, onResize);
            Game.ctrl.room.props.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onRoomPropertyChanged);
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

    protected function onRoomMessage (event :MessageReceivedEvent) :void
    {
        if (event.name == Codes.MESSAGE_CLEARED) {
            Game.ctrl.local.feedback(Messages.en.xlate("erased", Game.getName(int(event.value))));
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

            // Bind to top right
            _lock.x = screen.width-_lock.width;
            _lock.y = 0;
        }
    }

    protected function onRoomPropertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Codes.keyLock(_prefix)) {
            updateEnabled();
        }
    }

    protected function updateEnabled () :void
    {
        var locked :Boolean = Game.ctrl.room.props.get(Codes.keyLock(_prefix));
        var enabled :Boolean = _active && !locked;

        _toolbox.visible = enabled;
        _canvas.enabled = enabled;
        _lock.toggled = locked;
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

    [Embed(source="../../../res/lock.png")]
    protected static const ICON_LOCK :Class;
    [Embed(source="../../../res/unlock.png")]
    protected static const ICON_UNLOCK :Class;

    protected var _prefix :String;

    protected var _active :Boolean = true; // TODO

    protected static var _canvas :CanvasSprite;
    protected var _toolbox :Sprite;

    protected var _lock :ImageButton = new ImageButton(new ICON_LOCK(), new ICON_UNLOCK());

    // Transitions
    protected var _slideIn :GTween;
    protected var _fadeOut :GTween;
    protected var _transition :int = 0;
}

}
