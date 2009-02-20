package scribble.client {

import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent; // TODO: temp
import flash.geom.Rectangle; // TODO: temp
import flash.utils.Dictionary; // TODO: temp

import com.threerings.util.Command;
import com.threerings.util.ValueEvent;

import com.whirled.avrg.*;
import com.whirled.net.*;

import scribble.data.Codes;

public class ScribblePanel extends Sprite
{
    public function ScribblePanel ()
    {
        // For the eraser brush to work
        blendMode = flash.display.BlendMode.LAYER;

        Game.ctrl.room.props.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onRoomElementChanged);
        Game.ctrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onGameMessage);
        Game.ctrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, onEnteredRoom);

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
            var modes :Dictionary = Dictionary(Game.ctrl.room.props.get(Codes.PLAYER_MODES));
            if (modes == null) {
                trace("======== Modes dictionary not found!");
            }
            var mode :int = int(modes[Game.ctrl.player.getPlayerId()]);
            if (mode == Codes.CANVAS_ROOM) {
                mode = Codes.CANVAS_PICTIONARY;
            } else {
                mode = Codes.CANVAS_ROOM;
            }
            Command.dispatch(self, ScribbleController.CHANGE_MODE, mode);
        });
        addChild(switcher);
    }

    protected function onRoomElementChanged (event :ElementChangedEvent) :void
    {
        // Has the server put us in a new mode?
        if (event.name == Codes.PLAYER_MODES && event.key == Game.ctrl.player.getPlayerId()) {

            trace("==== Transitioning from " + event.oldValue + " to " + event.newValue);

            if (event.oldValue != null) {
                const oldMode :int = int(event.oldValue);
                if (oldMode in _modeSprites) {
                    _modeSprites[oldMode].didLeave();
                }
            }
            if (event.newValue != null) {
                const newMode :int = int(event.newValue);
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
    protected function onGameMessage (event :MessageReceivedEvent) :void
    {
        switch (event.name) {
            case Codes.MESSAGE_BROADCAST:
                Game.ctrl.local.feedback(Messages.en.xlate(event.value));
                break;

            case Codes.MESSAGE_FEED:
                // TODO: Show a nice little news ticker or something
                Game.ctrl.local.feedback(Messages.en.xlate(event.value));
                break;
        }
    }

    protected function onEnteredRoom (event :AVRGamePlayerEvent) :void
    {
        Command.dispatch(this, ScribbleController.CHANGE_MODE, Codes.CANVAS_ROOM);
    }

    /** Manages transitions. */
    protected const _modeSprites :Dictionary = new Dictionary(); // mode -> ModeSprite
}

}
