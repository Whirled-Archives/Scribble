package scribble.client {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;

import com.whirled.avrg.*;
import com.whirled.net.*;

import aduros.display.ToolTipManager;

import scribble.data.Codes;

public class ModeSwitcher extends Sprite
{
    public function ModeSwitcher (mode :int)
    {
        _mode = mode;

        graphics.beginFill(0x00ff00);
        graphics.drawRect(0, 0, 50, 50);
        graphics.endFill();
        addChild(_label);

        ToolTipManager.instance.attach(this, Messages.en.xlate("t_mode"+mode));
        Command.bind(this, MouseEvent.CLICK, ScribbleController.CHANGE_MODE, mode);

        Game.ctrl.room.props.addEventListener(ElementChangedEvent.ELEMENT_CHANGED,
            function (event :ElementChangedEvent) :void {
                if (event.name == Codes.PLAYER_MODES) {
                    if (event.oldValue === mode) {
                        setPopulation(_population-1);
                    }
                    if (event.newValue === mode) {
                        setPopulation(_population+1);
                    }
                }
            });

        Game.ctrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, onEnteredRoom);
    }

    protected function onEnteredRoom (event :AVRGamePlayerEvent) :void
    {
        var o :Object = Game.ctrl.room.props.get(Codes.PLAYER_MODES);
        trace("onEnteredRoom:"+_mode);
        for (var s :String in o) {
            trace(s +" = " + o[s]);
        }

        var n :int = 0;
        for each (var mode :int in Game.ctrl.room.props.get(Codes.PLAYER_MODES)) {
            if (mode == _mode) {
                n += 1;
            }
        }
        setPopulation(n);
    }

    public function setPopulation (population :int) :void
    {
        _population = population;
        _label.text = Messages.en.xlate("b_mode"+_mode, _population);
    }

    protected var _mode :int;
    protected var _population :int;

    protected var _label :TextField = TextFieldUtil.createField("",
        { textColor: 0xffffff, selectable: false, width: 0,
            autoSize: TextFieldAutoSize.LEFT, outlineColor: 0x00000 },
        { font: "_sans", size: 12, bold: true });
}

}
