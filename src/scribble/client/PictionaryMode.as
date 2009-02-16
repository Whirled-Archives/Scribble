package scribble.client {

import flash.display.Sprite;
import flash.utils.Dictionary;

import com.whirled.net.*;

import scribble.data.Codes;
import scribble.data.PictionaryLogic;

public class PictionaryMode extends ModeSprite
{
    public function PictionaryMode ()
    {
        _prefix = Codes.CANVAS_PREFIXES[Codes.CANVAS_PICTIONARY];
        _logic = new PictionaryLogic(_prefix, Game.ctrl.room.props);

        _canvas = new CanvasSprite(_prefix);
        addChild(_canvas);

        _tickerContainer.x = 200;
        addChild(_tickerContainer);

        _roster.x = 400;
        addChild(_roster);
    }

    public override function didEnter () :void
    {
        _canvas.init(false);
        updatePhase();
        initRoster();

        Game.ctrl.room.props.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onRoomPropertyChanged);
        Game.ctrl.room.props.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onRoomElementChanged);
    }

    public override function didLeave () :void
    {
        super.didLeave();

        Game.ctrl.room.props.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onRoomPropertyChanged);
        Game.ctrl.room.props.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, onRoomElementChanged);
    }

    protected function setTicker (duration :int) :void
    {
        clearTicker();
        _tickerContainer.addChild(
            new TickerSprite(Game.ctrl.room.props, Codes.keyTicker(_prefix), duration));
    }

    protected function clearTicker () :void
    {
        GraphicsUtil.removeAllChildren(_tickerContainer);
    }

    protected function updatePhase () :void
    {
        switch (Game.ctrl.room.props.get(Codes.keyPhase(_prefix))) {
            case Codes.PHASE_INTERMISSION:
                setTicker(20);
                Game.ctrl.local.feedback("= Intermission");
                break;

            case Codes.PHASE_PAUSE:
                clearTicker();
                Game.ctrl.local.feedback("= Pause");
                break;

            case Codes.PHASE_PLAYING:
                setTicker(10);
                Game.ctrl.local.feedback("= Playing");
                break;

            case Codes.PHASE_NOT_ENOUGH_PLAYERS:
                clearTicker();
                Game.ctrl.local.feedback("= Not enough players");
                break;
        }
    }

    protected function initRoster () :void
    {
        _roster.clear();

        var modes :Dictionary = Dictionary(Game.ctrl.room.props.get(Codes.PLAYER_MODES));
        var roster :Dictionary = _logic.getRoster();

        for (var key :String in roster) {
            var rosterId :int = int(key);
            var playerId :int = roster[rosterId];
            if (playerId in modes && modes[playerId] == Codes.CANVAS_PICTIONARY) {
                _roster.add(rosterId, Game.getName(playerId));
                _roster.setScore(rosterId, _logic.getScores()[rosterId]);
            }
        }
    }

    protected function onRoomPropertyChanged (event :PropertyChangedEvent) :void
    {
        switch (event.name) {
            case Codes.keyPhase(_prefix):
                updatePhase();
                break;

            case Codes.keyTurnHolder(_prefix):
                _roster.setTurnHolder(int(event.newValue));
                break;
        }
    }

    protected function onRoomElementChanged (event :ElementChangedEvent) :void
    {
        switch (event.name) {
            case Codes.PLAYER_MODES:
                if (event.oldValue == Codes.CANVAS_PICTIONARY) {
                    _roster.remove(_logic.getRosterId(event.key));
                }
                if (event.newValue == Codes.CANVAS_PICTIONARY) {
                    _roster.add(_logic.getRosterId(event.key), Game.getName(event.key));
                }
                break;

            case Codes.keyScores(_prefix):
                _roster.setScore(event.key, int(event.newValue));
                break;
        }
    }

    protected var _roster :RosterSprite = new RosterSprite();
    protected var _tickerContainer :Sprite = new Sprite();
    protected var _canvas :CanvasSprite;

    protected var _prefix :String;
    protected var _logic :PictionaryLogic;
}

}
