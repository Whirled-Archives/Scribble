package scribble.client {

import aduros.i18n.MessageBundle;

public class Messages
{
    public static const en :MessageBundle = new MessageBundle({
        broadcast: "Scribble broadcast by {0}: {1}",
        pass: "{0} passed on \"{1}\".",
        correct: "{0} and {1} get {2} points for \"{3}\"!",
        trophy: "{0} earned the {1} trophy!",
        joined: "{0} entered a room!",
        erased: "{0} cleared the canvas.",

        lock_denied: "There was a LockToy present, but you do not own this room.",
        lock_missing: "No LockToy found. Buy one at (TODO)."
    });
}

}
