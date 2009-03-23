package scribble.toolbench {

import flash.display.Sprite;

import com.whirled.*;

import scribble.data.Codes;

[SWF(width="60", height="60")]
public class Toolbench extends Sprite
{
    public function Toolbench ()
    {
        _ctrl = new ToyControl(this);

        _ctrl.registerPropertyProvider(function (key :String) :Object {
            return (key == Codes.PUBLIC_TOOLBENCH) ? true : null;
        });

        addChild(new ICON());
    }

    [Embed(source="../../../res/icon.png")]
    protected static const ICON :Class;

    protected var _ctrl :ToyControl;
}

}
