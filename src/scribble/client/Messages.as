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
        t_locate: "Find active rooms",
        t_quit: "Quit Scribble",
        t_turnHolder: "It is this person's turn to draw",
        t_walk: "Toggle walking/drawing",
        t_reference: "Google Image Search this word",
        t_mode0: "Doodle this room",
        t_mode1: "Play Scribble: Wordsketch",
        t_eraser: "Eraser",

        b_mode0: "Doodling ({0})",
        b_mode1: "Wordsketch ({0})",

        m_broadcast: "Scribble broadcast by {0}: {1}",
        m_trophy: "{0} earned the {1} trophy!",
        m_joined: "{0} logged on.",
        m_erased: "{0} cleared the canvas.",

        m_picto_notEnoughPlayers: "Not enough players here to play Scribble: Wordsketch. Why not invite a friend, or use the \"Find active rooms\" button?",
        m_picto_intermission: "Get ready! The next round of Scribble: Wordsketch will soon begin.",
        m_picto_pass: "{0} passed on \"{1}\".",
        m_picto_correct: "{0} and {1} get {2} points for \"{3}\"!",
        m_picto_guess: "{0}: {1}",
        m_picto_fail: "{0} ran out of time on \"{1}\".",
        m_picto_autoPass: "Auto-passing because you were away. Wake up!",
        m_picto_win: "{0} wins!",
        m_picto_go: "DRAW YOUR WORD!",

        t_picto_close: "Close Wordsketch",

        m_picto_score1: "Not Bad!",
        m_picto_score2: "OK!",
        m_picto_score3: "Good!",
        m_picto_score4: "Great!",
        m_picto_score5: "Marvellous!",
        //m_picto_score6: "Asshole!",

        m_doodle_walkOn: "You have enabled walking. Click the pencil icon to resume doodling.",
        m_doodle_lockOn: "This canvas is now locked. Only the room owners can doodle or unlock it for everyone.",
        m_doodle_lockOff: "This canvas is now UNLOCKED, anyone can doodle on it.",

        l_mode0: "Doodle",
        l_mode1: "Wordsketch",

        m_invite: "Check out this cool drawing game!",

        m_locatedHeader: "== Current Top 5 {0} rooms:",
        m_locatedRoom: "{2} players in {1}: http://www.whirled.com/#world-s{0}",
        m_locatedNone: "Nobody playing {0} :(",
        m_bye: "Thanks for playing Scribble. Come back soon!",

        m_welcome_newbie: "Welcome to Scribble. Play Wordsketch with friends or just have fun Doodling!",
        m_welcome: "Welcome back to Scribble! Join the community and find friends at http://www.whirled.com/#groups-d_10585 .",
        m_updated: "Scribble has been updated since you last played! Check out http://www.whirled.com/#groups-f_10585 for what changed."
    });
}

}
