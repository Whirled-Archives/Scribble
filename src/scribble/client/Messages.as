package scribble.client {

import aduros.i18n.MessageBundle;

public class Messages
{
    public static const en :MessageBundle = new MessageBundle({

        t_undo: "Undo",
        t_redo: "Redo",
        t_lock: "Lock/unlock canvas",
        t_pass: "Skip turn",
        t_invite: "Invite friends to play",
        t_clear: "Clear canvas",
        t_locate: "Find other players like me",
        t_quit: "Quit Scribble",
        t_turnHolder: "It is this person's turn to draw",
        t_walk: "Toggle walking/drawing",
        t_reference: "Google Image Search this word",
        t_mode0: "Doodle this room",
        t_mode1: "Play Wordsketch",

        b_mode0: "Doodling ({0})",
        b_mode1: "Wordsketch ({0})",

        m_broadcast: "Scribble broadcast by {0}: {1}",
        m_trophy: "{0} earned the {1} trophy!",
        m_joined: "{0} logged on.",
        m_erased: "{0} cleared the canvas.",

        m_picto_notEnoughPlayers: "Not enough players to play Wordsketch. Why not invite a friend?",
        m_picto_intermission: "Get ready! The next round of Scribble: Wordsketch will soon begin.",
        m_picto_pass: "{0} passed on \"{1}\".",
        m_picto_correct: "{0} and {1} get {2} points for \"{3}\"!",
        m_picto_guess: "{0}: {1}",
        m_picto_fail: "{0} ran out of time on \"{1}\".",
        m_picto_autoPass: "Auto-passing because you were away. Wake up!",
        t_picto_close: "Close Wordsketch",

        l_mode0: "Doodle",
        l_mode1: "Wordsketch",

        m_invite: "Check out this cool drawing game!",

        m_locateSuccess: "Found a {0} game with {1} players! Join them at http://www.whirled.com/#world-s{2}",
        m_locateFail: "No other games of {0} were found. Why not invite a friend?",
        m_bye: "Thanks for playing Scribble. Come back soon!",

        m_welcome_newbie: "OMG TODO",
        m_welcome: "Welcome back to Scribble!",
        m_updated: "Scribble has been updated since you last played! Check out http://www.whirled.com/#groups-f_10585 for what changed."
    });
}

}
