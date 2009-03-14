package scribble.client {

import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;

import com.gskinner.motion.GTween;

import com.whirled.net.*;

/** A smart component for showing a clock. */
public class TickerSprite extends Sprite
{
    public static const RADIUS :int = 50;

    public function TickerSprite (props :PropertyGetSubControl, name :String, max :int) :void
    {
        _name = name;
        _max = max;
        _props = props;

        addEventListener(Event.ADDED_TO_STAGE, function (... _) :void {
            _props.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropertyChanged);
        });
        addEventListener(Event.REMOVED_FROM_STAGE, function (... _) :void {
            _props.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropertyChanged);
        });

        _wedge.arc = 360;
        _wedge.filters = [ new DropShadowFilter() ];
        addChild(_wedge);

//        addChild(_time);

        update();
    }

    protected function onPropertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == _name) {
            update();
        }
    }

    protected function update () :void
    {
        var now :int = int(_props.get(_name));

        _wedge.arc = 360*(1-now/_max);

        if (_tween != null) {
            _tween.pause();
        }
        _tween = (_wedge.arc != 0) ? new GTween(_wedge, _max-now, {arc: 0}) : null;
    }

    protected var _name :String;
    protected var _max :int;
    protected var _props :PropertyGetSubControl;

//    protected var _time :TextField = TextFieldUtil.createField("",
//        { textColor: 0xffffff, selectable: false,
//            autoSize: TextFieldAutoSize.LEFT, outlineColor: 0x00000 },
//        { font: "_sans", size: 24, bold: true });

    protected var _wedge :Wedge = new Wedge(RADIUS);
    protected var _tween :GTween;
}

}
