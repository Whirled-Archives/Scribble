package scribble.locker {

import flash.display.Sprite;

import com.whirled.*;

import scribble.data.Codes;

public class Locker extends Sprite
{
    public function Locker ()
    {
        _ctrl = new ToyControl(this);

        _ctrl.registerPropertyProvider(function (key :String) :Boolean {
            return (key == Codes.PUBLIC_LOCKABLE && _ctrl.canManageRoom());
        });
    }

    protected var _ctrl :ToyControl;
}

}
