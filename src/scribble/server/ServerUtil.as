package scribble.server {

import flash.events.TimerEvent;
import flash.utils.Timer;

public class ServerUtil
{
    public static function callAfter (seconds :int, func :Function) :void
    {
        const timer :Timer = new Timer(1000*seconds, 1);
        timer.addEventListener(TimerEvent.TIMER_COMPLETE, function (... _) :void {
            func();
        });
        timer.start();
    }
}

}
