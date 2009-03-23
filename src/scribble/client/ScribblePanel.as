package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent; // TODO: temp
import flash.geom.Rectangle; // TODO: temp
import flash.utils.Dictionary; // TODO: temp

import com.gskinner.motion.GTween;

import com.threerings.util.Command;
import com.threerings.util.ValueEvent;

import com.whirled.*;
import com.whirled.avrg.*;
import com.whirled.net.*;

import aduros.display.ImageButton;
import aduros.display.ToolTipManager;

import scribble.data.Codes;

public class ScribblePanel extends Sprite
{
    public function ScribblePanel ()
    {
        Game.ctrl.room.props.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onRoomElementChanged);
        Game.ctrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, onEnteredRoom);
        Game.ctrl.player.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, onLeftRoom);
        Game.ctrl.room.addEventListener(ControlEvent.CHAT_RECEIVED, onChat);

        Game.ctrl.local.setMobSpriteExporter(function (name :String) :Sprite {
            if (name == Codes.MOB_FOREGROUND) {
                return new Sprite(); // We'll fill it up later
            } else {
                Game.log.warning("Non-overlay mob created? Prepare for breakage.");
                return null;
            }
        });

        var locator :ImageButton = new ImageButton(new SEARCH_ICON(),
            Messages.en.xlate("t_locate"));
        locator.addEventListener(MouseEvent.CLICK, function (... _) :void {
            Command.dispatch(locator, ScribbleController.LOCATE_PEERS, _localMode);
        });
        _buttonBar.addChild(locator);

        var invite :ImageButton = new ImageButton(new ICON_INVITE(),
            Messages.en.xlate("t_invite"));
        Command.bind(invite, MouseEvent.CLICK, ScribbleController.INVITE);
        invite.x = _buttonBar.width;
        _buttonBar.addChild(invite);

        var quit :ImageButton = new ImageButton(new EXIT_ICON(),
            Messages.en.xlate("t_quit"));
        Command.bind(quit, MouseEvent.CLICK, ScribbleController.QUIT);
        quit.x = _buttonBar.width;
        _buttonBar.addChild(quit);

        _buttonBar.graphics.beginFill(0, 0.6);
        _buttonBar.graphics.lineStyle(1, 0xc0c0c0);
        _buttonBar.graphics.drawRoundRect(-16, -100, _buttonBar.width+100, _buttonBar.height+100, 16);
        _buttonBar.graphics.endFill();

        addChild(_buttonBar);

        // Test stuff

        for each (var switcher :ModeSwitcher in _modeSwitchers) {
            addChild(switcher);
        }

        addChild(_modeArrow);

        Game.ctrl.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED, onResize);
        onResize();
    }

    protected function onResize (... _) :void
    {
        var screen :Rectangle = Game.ctrl.local.getPaintableArea();
        if (screen != null) {

            for (var ii :int = 0; ii < _modeSwitchers.length; ++ii) {
                _modeSwitchers[ii].x = screen.width - _modeSwitchers[ii].width;
                _modeSwitchers[ii].y = 45 + 20*ii;
            }
            _modeArrow.x = _modeSwitchers[0].x;

            _buttonBar.x = screen.width-_buttonBar.width+100-8;
            _buttonBar.y = 0;
        }
    }

    protected function onRoomElementChanged (event :ElementChangedEvent) :void
    {
        // Has the server put us in a new mode?
        if (event.name == Codes.PLAYER_MODES && event.key == Game.ctrl.player.getPlayerId()
            && event.newValue != event.oldValue) {

            // Transition out of the old mode
            if (_localMode in _modeSprites) {
                _modeSprites[_localMode].didLeave();
            }

            const newMode :int = int(event.newValue);
            _localMode = newMode;

            if (event.newValue != null) {
                if (newMode in _modeSprites) {
                    ModeSprite(_modeSprites[newMode]).didEnter();
                } else {
                    var ms :ModeSprite = (newMode == 0) ? new BackdropMode() : new PictionaryMode();
                    _modeSprites[newMode] = ms;
                    ms.addEventListener(Event.REMOVED_FROM_STAGE, function (... _) :void {
                        trace("Cleaning out " + newMode);
                        Game.log.info("Transition finished", "mode", newMode);
                        delete _modeSprites[newMode];
                    });
                    addChild(ms);
                    ms.didEnter();
                }
            }

            var switcher :Sprite = _modeSwitchers[newMode];
            new GTween(_modeArrow, 0.2, {y: switcher.y + switcher.height/2 - _modeArrow.height/2});
        }
    }

    protected function onLeftRoom (event :AVRGamePlayerEvent) :void
    {
        if (_localMode in _modeSprites) {
            removeChild(_modeSprites[_localMode]);
        } else {
            Game.log.warning("Couldn't clean up the current mode on room exit", "mode", _localMode);
        }
    }

    protected function onEnteredRoom (event :AVRGamePlayerEvent) :void
    {
        Command.dispatch(this, ScribbleController.CHANGE_MODE, Codes.CANVAS_ROOM);
    }

    protected function onChat (event :ControlEvent) :void
    {
        var playerId :int = Game.ctrl.player.getPlayerId();
        if (Codes.isAdmin(playerId) &&
            Game.ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, event.name) == playerId) {

            var command :Array = event.value.match(/^!(\w*)\s+(.*)/);
            if (command != null) {
                switch (command[1]) {
                    case "broadcast":
                        Command.dispatch(this, ScribbleController.BROADCAST, command[2]);
                        break;

                    default:
                        Game.ctrl.local.feedback("Not a command: " + command[1]);
                        break;
                }
            }
        }
    }

    public function getModeSprite () :ModeSprite
    {
        return _modeSprites[_localMode];
    }

    // Control bar buttons
    [Embed(source="../../../res/search.png")]
    protected static const SEARCH_ICON :Class;
    [Embed(source="../../../res/invite.png")]
    protected static const ICON_INVITE :Class;
    [Embed(source="../../../res/exit.png")]
    protected static const EXIT_ICON :Class;

    [Embed(source="../../../res/arrow_right.png")]
    protected static const MODE_ICON :Class;
    protected var _modeArrow :Bitmap = Bitmap(new MODE_ICON());

    /** Manages transitions. */
    protected const _modeSprites :Dictionary = new Dictionary(); // mode -> ModeSprite

    protected var _modeSwitchers :Array = [
        new ModeSwitcher(Codes.CANVAS_ROOM), new ModeSwitcher(Codes.CANVAS_PICTIONARY)
    ];

    /** The mode the client is running. */
    protected var _localMode :int;

    protected var _buttonBar :Sprite = new Sprite();
}

}
