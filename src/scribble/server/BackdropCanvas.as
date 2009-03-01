package scribble.server {

import scribble.data.Codes;

public class BackdropCanvas extends Canvas
{
    public function BackdropCanvas (mode :int, room :RoomManager)
    {
        super(mode, room.ctrl.props);

        if (room.ctrl.getMobSubControl(Codes.MOB_FOREGROUND) != null) {
            // Should only ever be called after a reboot
            room.ctrl.despawnMob(Codes.MOB_FOREGROUND);
        }

        // Note: It can't be at (0, 1, 0), that won't work with topdown backdrops
        room.ctrl.spawnMob(Codes.MOB_FOREGROUND, Codes.MOB_FOREGROUND, 0.5, 0, 0);
    }
}

}
