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
    public function setName (rosterId :int, name :String) :void
    {
        _entries[rosterId].name = name;
        _sprites[rosterId].nameLabel.text = name;

        updateUI();
    }

    public function setScore (rosterId :int, score :int) :void
    {
        _entries[rosterId].score = score;
        // TODO: Look at the original score, calculate the delta and show a nice little animation
        _sprites[rosterId].scoreLabel.text = String(score);

        updateUI();
    }

    public function setTurnHolder (rosterId :int) :void
    {
        if (_turnHolder >= 0) {
            _sprites[_turnHolder].removeChild(_turnArrow);
        }

        if (rosterId >= 0) {
            var newRow :RowSprite = _sprites[rosterId];
            if (_turnHolder >= 0) {
                _turnArrow.y = _sprites[_turnHolder].y - newRow.y;
                new GTween(_turnArrow, 0.2, {y: 0});
            } else {
                _turnArrow.y = 0;
            }
            newRow.addChild(_turnArrow);
        }

        _turnHolder = rosterId;
    }

    public function add (rosterId :int, name :String) :void
    {
        if (rosterId in _entries) {
            throw new Error("Player is already in this roster.");
        }

        _entries[rosterId] = new RosterEntry(name);

        var row :RowSprite = new RowSprite();

        for (var ii :String in _sprites) {
            if (int(ii) > rosterId) {
                _sprites[ii].y += RowSprite.HEIGHT;
            } else {
                row.y += RowSprite.HEIGHT;
            }
        }
        _sprites[rosterId] = row;

        addChild(row);

        setName(rosterId, name);
    }

    public function remove (rosterId :int) :void
    {
        if (!(rosterId in _entries)) {
            return;
        }

        // If he was the turn holder, remove the arrow
        if (rosterId == _turnHolder) {
            setTurnHolder(-1);
        }

        delete _entries[rosterId];

        removeChild(_sprites[rosterId]);
        delete _sprites[rosterId];

        // Bump up all the sprites after it
        for (var ii :String in _sprites) {
            if (int(ii) > rosterId) {
                _sprites[ii].y -= RowSprite.HEIGHT;
            }
        }

        updateUI();
    }

    protected function updateUI () :void
    {
        graphics.clear();

        graphics.beginFill(0xc0c0c0);
        graphics.drawRect(0, 0, RowSprite.WIDTH, height);
        graphics.endFill();
    }

    public function clear () :void
    {
        // TODO: Remove all entries
    }

    protected var _entries :Object = {}; // rosterId -> RosterEntry
    protected var _turnHolder :int = -1;

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
    /** Height of this sprite, plus padding. */
    public static const HEIGHT :int = 14;

    /** Because right aligned fields don't seem to affect sprite width... */
    public static const WIDTH :int = 180;

    public var nameLabel :TextField;
    public var scoreLabel :TextField;

    public function RowSprite ()
    {
        nameLabel = TextFieldUtil.createField("",
            { x: 20, textColor: 0xffffff, selectable: false,
                autoSize: TextFieldAutoSize.LEFT, outlineColor: 0x00000 },
            { font: "_sans", size: 12, bold: true });
        scoreLabel = TextFieldUtil.createField("test",
            { textColor: 0x00ff00, selectable: false,
                outlineColor: 0x00000, width: 0, x: WIDTH, autoSize: TextFieldAutoSize.RIGHT },
            { font: "_sans", size: 12, bold: true });

        addChild(nameLabel);
        addChild(scoreLabel);
    }
}
