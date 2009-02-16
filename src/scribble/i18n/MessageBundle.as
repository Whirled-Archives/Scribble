package scribble.i18n {

import com.threerings.util.Log;
import com.threerings.util.Util;

/** A super bare bones localization helper. */
public class MessageBundle
{
    public static const log :Log = Log.getLog(MessageBundle);

    public function MessageBundle (messages :Object)
    {
        _messages = messages;
    }

    public function xlate (... args) :String
    {
        args = Util.unfuckVarargs(args);
        var key :String = args.shift() as String;
        var text :String;

        if (key in _messages) {
            text = _messages[key];
            for (var ii :int = 0; ii < args.length; ++ii) {
                text = text.replace("{"+ii+"}", args[ii]);
            }

        } else {
            text = key + ":" + args.join();
            log.warning("Missing translation", "key", key, "args", args);
        }

        return text;
    }

    protected var _messages :Object;
}

}
