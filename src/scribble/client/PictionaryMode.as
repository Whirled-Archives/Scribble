package scribble.client {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import com.gskinner.motion.GTween;

import com.threerings.text.TextFieldUtil;
import com.threerings.util.Command;

import com.whirled.*;
import com.whirled.avrg.*;
import com.whirled.net.*;

import aduros.display.DisplayUtil;
import aduros.display.ImageButton;
import aduros.net.REMOTE;

import scribble.data.Codes;
import scribble.data.PictionaryLogic;

public class PictionaryMode extends ModeSprite
{
    public static const CANVAS_WIDTH :int = 400;
    public static const CANVAS_HEIGHT :int = 300;
    public static const SPACING :int = 8;

    public function PictionaryMode ()
    {
        _prefix = Codes.CANVAS_PREFIXES[Codes.CANVAS_PICTIONARY];
        _logic = new PictionaryLogic(_prefix, Game.ctrl.room.props);

        _panel = new Sprite();
        _panel.graphics.beginFill(0xffffff);
        _panel.graphics.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        _panel.graphics.endFill();
        _panel.filters = [ new DropShadowFilter() ];

        _canvas = new CanvasSprite(_prefix, CANVAS_WIDTH, CANVAS_HEIGHT);
        _panel.addChild(_canvas);

        _wordField.mouseEnabled = false;
        _panel.addChild(_wordField);

        _hintField.mouseEnabled = false;
        _panel.addChild(_hintField);

        _tickerContainer.x = CANVAS_WIDTH + RosterSprite.WIDTH/2 - TickerSprite.RADIUS;
        _tickerContainer.y = SPACING;
        _panel.addChild(_tickerContainer);

        _roster.x = CANVAS_WIDTH;
        _roster.y = 2*TickerSprite.RADIUS + 2*SPACING + 1;
        _panel.addChild(_roster);

        _toolbox = _canvas.createToolbox();
        _toolbox.x = 4;
        _toolbox.y = CANVAS_HEIGHT;
        _toolbox.graphics.beginFill(0, 0.6);
        _toolbox.graphics.lineStyle(1, 0xc0c0c0);
        _toolbox.graphics.drawRect(-_toolbox.x, 0, CANVAS_WIDTH, _toolbox.height);
        _toolbox.graphics.endFill();
        _panel.addChild(_toolbox);

        _panel.graphics.beginFill(0, 0.6);
        _panel.graphics.lineStyle(1, 0xc0c0c0);
        _panel.graphics.drawRect(CANVAS_WIDTH, 0, RosterSprite.WIDTH, 2*SPACING + 2*TickerSprite.RADIUS);
        _panel.graphics.endFill();

        addChild(_panel);

        _turnHolderControls.x = CANVAS_WIDTH;

        Command.bind(_passButton, MouseEvent.CLICK, ScribbleController.PICTIONARY_PASS);
        _turnHolderControls.addChild(_passButton);

        _referenceButton.x = _passButton.width;
        _referenceButton.addEventListener(MouseEvent.CLICK, function (... _) :void {
            var data :URLVariables = new URLVariables();
            data.hl = "en";
            data.q = _wordField.text;

            var url :URLRequest = new URLRequest("http://images.google.com/images");
            url.data = data;

            flash.net.navigateToURL(url, "_blank");
        });
        _turnHolderControls.addChild(_referenceButton);

        // Button to return to backdrop drawing mode
        _closeButton.x = _panel.width - _closeButton.width - 6;
        _closeButton.y = 2;
        Command.bind(_closeButton, MouseEvent.CLICK,
            ScribbleController.CHANGE_MODE, Codes.CANVAS_ROOM);
        _panel.addChild(_closeButton);

        var screen :Rectangle = Game.ctrl.local.getPaintableArea();

        _panel.y = -_panel.height;
        _slideIn = new GTween(_panel, 2, {y: (screen.height-_panel.height)/2}, {autoPlay: false});
        _slideIn.addEventListener(Event.COMPLETE, onSlideComplete);

        onResize();

        addEventListener(Event.ADDED_TO_STAGE, function (... _) :void {
            _canvas.init(false);
            updatePhase();
            initRoster();

            Game.ctrl.room.props.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onRoomPropertyChanged);
            Game.ctrl.room.props.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onRoomElementChanged);
            Game.ctrl.room.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onRoomMessage);
            Game.ctrl.local.addEventListener(AVRGameControlEvent.SIZE_CHANGED, onResize);
            Game.ctrl.room.addEventListener(ControlEvent.CHAT_RECEIVED, onChat);
        });
        addEventListener(Event.REMOVED_FROM_STAGE, function (... _) :void {
            Game.ctrl.room.props.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onRoomPropertyChanged);
            Game.ctrl.room.props.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, onRoomElementChanged);
            Game.ctrl.room.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onRoomMessage);
            Game.ctrl.local.removeEventListener(AVRGameControlEvent.SIZE_CHANGED, onResize);
            Game.ctrl.room.removeEventListener(ControlEvent.CHAT_RECEIVED, onChat);
        });
    }

    protected function onResize (... _) :void
    {
        var screen :Rectangle = Game.ctrl.local.getPaintableArea();
        if (screen != null) {
            _panel.x = (screen.width-_panel.width)/2; // Center horizontal
        }
    }

    public override function didEnter () :void
    {
        if (_slideIn.state == GTween.BEGINNING) {
            _slideIn.play();
        } else {
            GraphicsUtil.flip(_slideIn);
            _transitionReversed = !_transitionReversed;
        }
    }

    protected function onSlideComplete (event :Event) :void
    {
        if (_transitionReversed) {
            super.didLeave();
        }
    }

    public override function didLeave () :void
    {
        GraphicsUtil.flip(_slideIn);
        _transitionReversed = !_transitionReversed;
    }

    protected function setTicker (duration :int) :void
    {
        clearTicker();
        _tickerContainer.addChild(
            new TickerSprite(Game.ctrl.room.props, Codes.keyTicker(_prefix), duration));
    }

    protected function clearTicker () :void
    {
        DisplayUtil.removeAllChildren(_tickerContainer);
    }

    protected function updatePhase () :void
    {
        var canDraw :Boolean = _logic.canDraw(Game.ctrl.player.getPlayerId());

        DisplayUtil.setContains(_panel, _toolbox, canDraw);
        _canvas.enabled = canDraw;

        var phase :int = _logic.getPhase();

        switch (phase) {
            case PictionaryLogic.PHASE_INTERMISSION:
                setTicker(PictionaryLogic.DELAY_INTERMISSION);
                Game.ctrl.local.feedback(Messages.en.xlate("m_picto_intermission"));
                break;

            case PictionaryLogic.PHASE_PAUSE:
                clearTicker();
                break;

            case PictionaryLogic.PHASE_PLAYING:
                setTicker(PictionaryLogic.DELAY_PLAYING);
                setHint(_logic.getHint());
                break;

            case PictionaryLogic.PHASE_NOT_ENOUGH_PLAYERS:
                clearTicker();
                Game.ctrl.local.feedback(Messages.en.xlate("m_picto_notEnoughPlayers"));
                setHint(null);
                break;
        }

        var isMyTurn :Boolean = (phase == PictionaryLogic.PHASE_PLAYING && canDraw);

        // Use visible here instead of setContains to not mess with the z-order
        _wordField.visible = isMyTurn;
        DisplayUtil.setContains(_panel, _turnHolderControls, isMyTurn);

        if (canDraw) {
            _toolbox.reset();
        }

        if (isMyTurn) {
            // Auto-pass when idle
            if (Game.ctrl.room.getAvatarInfo(Game.ctrl.player.getPlayerId()).isIdle) {
                Game.ctrl.local.feedback(Messages.en.xlate("m_picto_autoPass"));
                Command.dispatch(this, ScribbleController.PICTIONARY_PASS);
            } else {
                showMessage(Messages.en.xlate("m_picto_go"), 1, 0xff0000);
            }
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
            var scores :Dictionary = _logic.getScores();
            if (playerId in modes && modes[playerId] == Codes.CANVAS_PICTIONARY) {
                _roster.add(rosterId, Game.getName(playerId),
                    playerId == Game.ctrl.player.getPlayerId());
                _roster.setScore(rosterId, scores[rosterId]);
            }
        }

        var turnHolder :int = _logic.getTurnHolder();
        if (roster[turnHolder] in modes) {
            _roster.setTurnHolder(turnHolder);
        } else {
            // This happened when Sivius crashed as the turn holder
            Game.log.warning("Booch! Turn holder not in room");
        }
    }

    protected function onRoomPropertyChanged (event :PropertyChangedEvent) :void
    {
        switch (event.name) {
            case Codes.keyPhase(_prefix):
                updatePhase();
                break;

            case Codes.keyTurnHolder(_prefix):
                _roster.setTurnHolder(event.newValue != null ? int(event.newValue) : -1);
                break;

            case Codes.keyScores(_prefix):
                if (event.newValue == null) {
                    for (var rosterId :String in _logic.getRoster()) {
                        _roster.setScore(int(rosterId), 0);
                    }
                } else {
                    Game.log.warning("Scores set to something other than null?", "value", event.newValue);
                }
                break;

            case Codes.keyHint(_prefix):
                setHint(_logic.getHint());
                break;
        }
    }

    protected function onRoomElementChanged (event :ElementChangedEvent) :void
    {
        switch (event.name) {
            case Codes.PLAYER_MODES:
                var rosterId :int = _logic.getRosterId(event.key);
                if (event.oldValue == Codes.CANVAS_PICTIONARY) {
                    _roster.remove(rosterId);
                }
                if (event.newValue == Codes.CANVAS_PICTIONARY) {
                    _roster.add(rosterId, Game.getName(event.key),
                        event.key == Game.ctrl.player.getPlayerId());
                    _roster.setScore(rosterId, _logic.getScores()[rosterId]);
                }
                break;

            case Codes.keyScores(_prefix):
                _roster.setScore(event.key, int(event.newValue));
                break;
        }
    }

    protected function onRoomMessage (event :MessageReceivedEvent) :void
    {
        switch (event.name) {
            case Codes.msgPass(_prefix):
                Game.ctrl.local.feedback(Messages.en.xlate("m_picto_pass",
                    Game.getName(_logic.getPlayerId(_logic.getTurnHolder())), event.value));
                setHint(event.value as String);
                break;

            case Codes.msgCorrect(_prefix):
                var drawerId :int = _logic.getPlayerId(_logic.getTurnHolder());
                var guesserId :int = event.value[0];
                var word :String = event.value[1];
                var points :int = event.value[2];
                var myId :int = Game.ctrl.player.getPlayerId();

                Game.ctrl.local.feedback(Messages.en.xlate("m_picto_correct",
                    Game.getName(event.value[0]), Game.getName(drawerId), points, word));
                setHint(word);

                if (drawerId == myId || guesserId == myId) {
                    showMessage(Messages.en.xlate("m_picto_score"+int((points+1)/2)), 2);
                }
                break;

            case Codes.msgFail(_prefix):
                Game.ctrl.local.feedback(Messages.en.xlate("m_picto_fail",
                    Game.getName(_logic.getPlayerId(_logic.getTurnHolder())), event.value));
                setHint(event.value as String);
                break;

            case Codes.msgWinners(_prefix):
                var winnerIds :Array = event.value as Array;
                var text :String = Messages.en.xlate("m_picto_win",
                    winnerIds.map(function (playerId :int, ... _) :String {
                        return Game.getName(playerId);
                    }).join(", "));
                showMessage(text, 5);
                Game.ctrl.local.feedback(text);
                break;
        }
    }

    protected function showMessage (message :String, speed :Number, color :int = 0x195f85) :void
    {
        var tf :TextField = TextFieldUtil.createField(message,
            { embedFonts: true, textColor: color, selectable: false,
                autoSize: TextFieldAutoSize.LEFT },
            { font: "scribble", size: 36 });

        tf.x = _canvas.width/2 - tf.textWidth/2;
        tf.y = 0;
        tf.filters = [ new DropShadowFilter(2) ]; // Everything's better with a drop shadow!
        tf.alpha = 0.2;

        var fadeOut :GTween = new GTween(tf, speed/4, {alpha: 0, y: 200}, {delay: speed, autoPlay: false});
        var fadeIn :GTween = new GTween(tf, speed/4, {alpha: 1, y: 100}, {nextTween: fadeOut});

        _canvas.addChild(tf);
        fadeOut.addEventListener(Event.COMPLETE, function (... _) :void {
            _canvas.removeChild(tf);
        });
    }

    protected function setHint (hint :String) :void
    {
        if (hint == null) {
            _hintField.visible = false;
        } else {
            _hintField.visible = true;
            _hintField.text = hint;
        }
    }

    protected function onChat (event :ControlEvent) :void
    {
        var playerId :int = Game.ctrl.player.getPlayerId();
        if (Game.ctrl.room.getEntityProperty(EntityControl.PROP_MEMBER_ID, event.name) == playerId
            && _logic.canGuess(playerId)) {
            Command.dispatch(this, ScribbleController.PICTIONARY_GUESS,
                PictionaryLogic.normalizeWord(event.value as String));
        }
    }

    REMOTE function sendWord (word :String) :void
    {
        _wordField.text = word;
        _wordField.x = CANVAS_WIDTH - SPACING - _wordField.textWidth;
        Game.log.info("Got word to draw", "word", word);
    }

    protected var _panel :Sprite = new Sprite(); // Holds the goods

    protected var _roster :RosterSprite = new RosterSprite();
    protected var _tickerContainer :Sprite = new Sprite();
    protected var _canvas :CanvasSprite;

    protected var _toolbox :ToolboxSprite;

    [Embed(source="../../../res/pass.png")]
    protected static const ICON_PASS :Class;
    protected var _passButton :ImageButton = new ImageButton(
        new ICON_PASS(), Messages.en.xlate("t_pass"));

    [Embed(source="../../../res/image.png")]
    protected static const ICON_REFERENCE :Class;
    protected var _referenceButton :ImageButton = new ImageButton(
        new ICON_REFERENCE(), Messages.en.xlate("t_reference"));

    [Embed(source="../../../res/close.png")]
    protected static const ICON_CLOSE :Class;
    protected var _closeButton :ImageButton = new ImageButton(
        new ICON_CLOSE(), Messages.en.xlate("t_picto_close"));

    protected var _turnHolderControls :Sprite = new Sprite();

    [Embed(source="../../../res/scribble.ttf", fontFamily="scribble")]
    protected static const FONT_SCRIBBLE :String;

    protected var _wordField :TextField = TextFieldUtil.createField("",
        { embedFonts: true, textColor: 0x999999, selectable: false, width: 0,
            y: CANVAS_HEIGHT-24-SPACING, outlineColor: 0xffffff,
            autoSize: TextFieldAutoSize.LEFT },
        { font: "scribble", size: 24 });

    protected var _hintField :TextField = TextFieldUtil.createField("",
        { embedFonts: true, textColor: 0, selectable: false, width: 0,
            x: 0, y: 0, outlineColor: 0xffffff,
            autoSize: TextFieldAutoSize.LEFT },
        { font: "scribble", size: 24 });

    protected var _prefix :String;
    protected var _logic :PictionaryLogic;

    protected var _slideIn :GTween;
    protected var _transitionReversed :Boolean;
}

}
