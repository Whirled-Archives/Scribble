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
        t_locate: "Find other players like me",
        t_quit: "Quit Scribble",
        t_picto_turnHolder: "It is this person's turn to draw",

        broadcast: "Scribble broadcast by {0}: {1}",
        trophy: "{0} earned the {1} trophy!",
        joined: "{0} entered a room!",
        erased: "{0} cleared the canvas.",

        picto_not_enough_players: "Not enough players to play (TODO). Why not invite a friend?",
        picto_intermission: "Get ready! The next round of (TODO) will soon begin.",
        picto_pass: "{0} passed on \"{1}\".",
        picto_correct: "{0} and {1} get {2} points for \"{3}\"!",
        picto_invite: "(TODO)",
        picto_guess: "{0}: {1}",
        picto_fail: "{0} ran out of time on \"{1}\".",

        // TODO: Get better names
        l_mode0: "Backdrop Mode",
        l_mode1: "Pictionary Mode",

        m_invite: "Check out this cool drawing game!",

        m_locate_success: "Found a {0} game with {1} players! Join them at http://www.whirled.com/#world-s{2}",
        m_locate_fail: "No other games of {0} were found. Why not invite a friend?",
        m_bye: "Thanks for playing Scribble. Come back soon!"
    });
}

}
