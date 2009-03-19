package scribble.client {

import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.gskinner.motion.GTween;

import com.threerings.flash.TextFieldUtil;

import com.whirled.net.*;

import scribble.data.Codes;

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
//        _wedge.filters = [ new DropShadowFilter() ];
        addChild(_wedge);

        addChild(_timeField);

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
            _tween = null;
        }

        if (_wedge.arc != 0) {
            _tween = new GTween(_wedge, Codes.TICKER_GRANULARITY*(_max-now)/1000, {arc: 0});
            _tween.addEventListener(Event.CHANGE, function (... _) :void {
                var p :Number = _wedge.arc/360;
                var minutes :int = Codes.TICKER_GRANULARITY/1000*(_max*p)/60;
                var seconds :int = Codes.TICKER_GRANULARITY/1000*(_max*p)%60;
                _timeField.text = minutes + ":" + (seconds >= 10 ? seconds : "0"+seconds);
            });
        }
    }

    protected var _name :String;
    protected var _max :int;
    protected var _props :PropertyGetSubControl;

    protected var _timeField :TextField = TextFieldUtil.createField("",
        { textColor: 0xffffff, selectable: false, alpha: 0.3,
            x: RADIUS+20, y: RADIUS+25, autoSize: TextFieldAutoSize.LEFT, outlineColor: 0x00000 },
        { font: "_sans", size: 24, bold: true });

    protected var _wedge :Wedge = new Wedge(RADIUS);
    protected var _tween :GTween;
}

}
