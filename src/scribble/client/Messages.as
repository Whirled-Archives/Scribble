package scribble.client {

import aduros.i18n.MessageBundle;

public class Messages
{
    public static const en :MessageBundle = new MessageBundle({

        t_undo: "Undo",
        t_redo: "Redo",
        t_lock: "Lock/unlock backdrop canvas",
        t_pass: "Skip turn",
        t_invite: "Invite friends to play",
        t_clear: "Clear canvas",

        broadcast: "Scribble broadcast by {0}: {1}",
        trophy: "{0} earned the {1} trophy!",
        joined: "{0} entered a room!",
        erased: "{0} cleared the canvas.",

        lock_denied: "There was a LockToy present, but you do not own this room.",
        lock_missing: "No LockToy found. Buy one at (TODO).",

        picto_not_enough_players: "Not enough players to play (TODO). Why not invite a friend?",
        picto_intermission: "Get ready! The next round of (TODO) will soon begin.",
        picto_pass: "{0} passed on \"{1}\".",
        picto_correct: "{0} and {1} get {2} points for \"{3}\"!",
        picto_invite: "(TODO)",
        picto_guess: "{0}: {1}",
        picto_fail: "{0} ran out of time on \"{1}\"."
    });
}

}
