package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.filters.DropShadowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.gskinner.motion.GTween;

import com.threerings.flash.TextFieldUtil;
import com.threerings.util.SortedHashMap;

/** A component for rendering a list of people. */
public class RosterSprite extends Sprite
{
    public function RosterSprite ()
    {
        _turnArrow.y = -500; // TODO
        _turnArrow.visible = false;
        addChild(_turnArrow);
    }

    public function setName (rosterId :int, name :String) :void
    {
        _sprites[rosterId].nameLabel.text = name;
    }

    public function setScore (rosterId :int, score :int) :void
    {
        // TODO: Look at the original score, calculate the delta and show a nice little animation
        _sprites[rosterId].scoreLabel.text = String(score);
    }

    public function setTurnHolder (rosterId :int) :void
    {
        _turnHolder = rosterId;

        // TODO: Look at the current turn holder, do a nice transition to the new one
        // If turnArrow was not visible, no transition
        _turnArrow.y = _sprites[rosterId].y;
        _turnArrow.visible = true;
    }

    public function add (rosterId :int, name :String) :void
    {
        if (rosterId in _entries) {
            throw new Error("Player is already in this roster.");
        }

        _entries[rosterId] = new RosterEntry(name);

        var row :RowSprite = new RowSprite();
        row.nameLabel.text = name;
        row.scoreLabel.text = "(None)";
        row.x = 25;

        trace("Added: rosterId="+rosterId+", name="+name);

        for (var ii :String in _sprites) {
            if (int(ii) > rosterId) {
                _sprites[ii].y += 20;
            } else {
                row.y += 20;
            }
        }
        _sprites[rosterId] = row;

        addChild(row);
    }

    public function remove (rosterId :int) :void
    {
        if (!(rosterId in _entries)) {
            return;
        }

        delete _entries[rosterId];

        removeChild(_sprites[rosterId]);
        delete _sprites[rosterId];

        // If he was the turn holder, hide the arrow
        if (rosterId == _turnHolder) {
            _turnArrow.visible = false;
        }

        // Bump up all the sprites after it
        for (var ii :String in _sprites) {
            if (int(ii) > rosterId) {
                _sprites[ii].y -= 20;
            }
        }
    }

    public function clear () :void
    {
        // TODO: Remove all entries
    }

    protected var _entries :Object = {}; // rosterId -> RosterEntry
    protected var _turnHolder :int;

    protected var _sprites :Object = {}; // rosterId -> RowSprite

    [Embed(source="../../../res/arrow.png")]
    protected static const TURN_ICON :Class;
    protected var _turnArrow :Bitmap = Bitmap(new TURN_ICON());
}

}

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import com.threerings.flash.TextFieldUtil;

class RosterEntry
{
    public var score :int;
    public var name :String;

    public function RosterEntry (name :String)
    {
        this.name = name;
    }
}

class RowSprite extends Sprite
{
    public var nameLabel :TextField;
    public var scoreLabel :TextField;

    public function RowSprite ()
    {
        nameLabel = TextFieldUtil.createField("",
            { textColor: 0xffffff, selectable: false,
                width: 200, outlineColor: 0x00000 },
            { font: "_sans", size: 24, bold: true });
        scoreLabel = TextFieldUtil.createField("",
            { textColor: 0x0000ff, selectable: false,
                x: 200, width: 100, outlineColor: 0x00000 },
            { font: "_sans", size: 24, bold: true });

        addChild(nameLabel);
        addChild(scoreLabel);
    }
}
