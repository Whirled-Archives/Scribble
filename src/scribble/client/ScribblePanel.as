package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent; // TODO: temp
import flash.geom.Rectangle; // TODO: temp
import flash.utils.Dictionary; // TODO: temp

import com.threerings.util.Command;
import com.threerings.util.ValueEvent;

import com.whirled.avrg.*;
import com.whirled.net.*;

import aduros.display.ImageButton;

import scribble.data.Codes;

public class ScribblePanel extends Sprite
{
    public function ScribblePanel ()
    {
        Game.ctrl.room.props.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onRoomElementChanged);
        Game.ctrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, onEnteredRoom);
        Game.ctrl.player.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, onLeftRoom);

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
        addChild(locator);

        var quit :ImageButton = new ImageButton(new EXIT_ICON(),
            Messages.en.xlate("t_quit"));
        Command.bind(quit, MouseEvent.CLICK, ScribbleController.QUIT);
        addChild(quit);
        quit.x = 32;

        // Test stuff
        var switcher :Sprite = new Sprite();
        switcher.graphics.beginFill(0x00ff00);
        switcher.graphics.drawRect(0, 0, 50, 50);
        switcher.graphics.endFill();
        var rect :Rectangle = Game.ctrl.local.getPaintableArea();
        switcher.x = rect.width - 60;
        switcher.y = rect.height - 60;
        const self :ScribblePanel = this;
        switcher.addEventListener(MouseEvent.CLICK, function (... _) :void {
            Command.dispatch(self, ScribbleController.CHANGE_MODE,
                _localMode == Codes.CANVAS_ROOM ? Codes.CANVAS_PICTIONARY : Codes.CANVAS_ROOM);
        });
        addChild(switcher);
    }

    protected function onRoomElementChanged (event :ElementChangedEvent) :void
    {
        // Has the server put us in a new mode?
        if (event.name == Codes.PLAYER_MODES && event.key == Game.ctrl.player.getPlayerId()) {

            Game.log.info("Transition", "oldMode", event.oldValue, "newMode", event.newValue);

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
                        delete _modeSprites[newMode];
                    });
                    addChild(ms);
                    ms.didEnter();
                }
            }
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

    public function getModeSprite () :ModeSprite
    {
        return _modeSprites[_localMode];
    }

    [Embed(source="../../../res/search.png")]
    protected static const SEARCH_ICON :Class;
    [Embed(source="../../../res/exit.png")]
    protected static const EXIT_ICON :Class;

    /** Manages transitions. */
    protected const _modeSprites :Dictionary = new Dictionary(); // mode -> ModeSprite

    /** The mode the client is running. */
    protected var _localMode :int;
}

}
