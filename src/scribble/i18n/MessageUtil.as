package scribble.i18n {

public class MessageUtil
{
    public static function pack (key :String, ... args) :Array
    {
        args.unshift(key);
        return args;
    }
}

}
