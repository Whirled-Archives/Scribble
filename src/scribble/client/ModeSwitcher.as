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

        ToolTipManager.instance.attach(this, Messages.en.xlate("t_mode"+mode));
        Command.bind(this, MouseEvent.CLICK, ScribbleController.CHANGE_MODE, mode);
        GraphicsUtil.throttleClicks(this);

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

        graphics.beginFill(0, 0.6);
        graphics.drawRect(0, 0, 140, 20);
        graphics.lineStyle(1, 0xc0c0c0);
        graphics.lineTo(140, 0);
        graphics.endFill();
        addChild(_label);

        Game.ctrl.player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, onEnteredRoom);

        this.buttonMode = true;
    }

    protected function onEnteredRoom (event :AVRGamePlayerEvent) :void
    {
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
        _label.textColor = (_population > 0) ? 0xff9900 : 0xffffff;
    }

    protected var _mode :int;
    protected var _population :int;

    protected var _label :TextField = TextFieldUtil.createField("",
        { selectable: false, x: 20, width: 0,
            autoSize: TextFieldAutoSize.LEFT, outlineColor: 0x00000 },
        { font: "_sans", size: 12, bold: true });
}

}
