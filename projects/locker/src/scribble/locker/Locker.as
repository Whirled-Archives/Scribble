package scribble.locker {

import flash.display.Sprite;

import com.whirled.*;

import scribble.data.Codes;

[SWF(width="128", height="128")]
public class Locker extends Sprite
{
    public function Locker ()
    {
        _ctrl = new ToyControl(this);

        _ctrl.registerPropertyProvider(function (key :String) :Boolean {
            return (key == Codes.PUBLIC_LOCKABLE && _ctrl.canManageRoom());
        });

        addChild(new ICON());
    }

    [Embed(source="../../../res/icon.png")]
    protected static const ICON :Class;

    protected var _ctrl :ToyControl;
}

}
