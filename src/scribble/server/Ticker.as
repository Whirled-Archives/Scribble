package scribble.server {

import flash.events.TimerEvent;
import flash.utils.Timer;

import com.whirled.net.PropertySubControl;

public class Ticker
{
    public function Ticker (props :PropertySubControl, name :String) :void
    {
        _props = props;
        _name = name;
    }

    public function start (
        duration :int, networked :Boolean, onComplete :Function = null) :void
    {
        // TODO: Verify that this is causing problems
//        if (duration <= 0) {
//            throw new ArgumentError("Duration must be > 0");
//        }
//
//        stop();
//
//        if (networked) {
//            _timer = new Timer(1000, duration);
//            _timer.addEventListener(TimerEvent.TIMER, tick);
//            tick(); // Immediately shoot an event now for the '0' tick
//        } else {
//            _timer = new Timer(1000*duration, 1);
//        }
//        if (onComplete != null) {
//            _timer.addEventListener(TimerEvent.TIMER_COMPLETE, function (... _) :void {
//                onComplete();
//            });
//        }
//
//        _timer.start();
    }

    public function stop () :void
    {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    protected function tick (... _) :void
    {
        _props.set(_name, _timer.currentCount);
    }

    protected var _props :PropertySubControl;
    protected var _name :String;
    protected var _timer :Timer;
}

}
