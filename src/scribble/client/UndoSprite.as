package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;

import com.threerings.util.Command;

import aduros.display.ImageButton;

import scribble.data.Stroke;

public class UndoSprite extends Sprite
{
    public function UndoSprite (canvas :CanvasSprite)
    {
        canvas.addEventListener(StrokeEvent.STROKE_ADDED,
            function (event :StrokeEvent) :void {
                if (event.isMyStroke()) {
                    if (event.stroke.isBeginning) {
                        _workingGroup = [];
                    }
                    _workingGroup.push(event);
                    if (event.stroke.isEnding) {
                        _undoStack.push(_workingGroup);
                        _undoButton.mouseEnabled = true;
                    }
                }
            });
        canvas.addEventListener(CanvasSprite.CANVAS_CLEARED, function (... _) :void {
            reset();
        });

        _undoButton = new ImageButton(Bitmap(new ICON_UNDO()), Messages.en.xlate("t_undo"));
//        var un :Sprite = new Sprite();
//        un.graphics.beginFill(0x00ff00);
//        un.graphics.drawRect(0, 0, 32, 32);
//        un.graphics.endFill();
//        Command.bind(un, MouseEvent.CLICK, undo);
//        addChild(un);
        Command.bind(_undoButton, MouseEvent.CLICK, undo);
        addChild(_undoButton);

        _redoButton = new ImageButton(Bitmap(new ICON_REDO()), Messages.en.xlate("t_redo"));
        Command.bind(_redoButton, MouseEvent.CLICK, redo);
        _redoButton.x = 32;
        addChild(_redoButton);

        reset();
    }

    public function undo () :void
    {
        if (_undoStack.length > 0) {
            var events :Array = _undoStack.pop();
            _redoStack.push(events);

            _undoButton.mouseEnabled = (_undoStack.length > 0);
            _redoButton.mouseEnabled = true;

            Command.dispatch(this, ScribbleController.REMOVE_STROKES,
                events.map(function(event :StrokeEvent, ... _) :int {
                    return event.strokeId;
                }));
        }
    }

    public function redo () :void
    {
        if (_redoStack.length > 0) {
            var events :Array = _redoStack.pop();
            // (It's pushed onto the undo stack in the event listener)

            _redoButton.mouseEnabled = (_redoStack.length > 0);

            Command.dispatch(this, ScribbleController.SEND_STROKE,
                events.map(function(event :StrokeEvent, ... _) :Stroke {
                    return event.stroke;
                }));
        }
    }

    public function clearRedo () :void
    {
        _redoStack = [];
        _redoButton.mouseEnabled = false;
    }

    public function reset () :void
    {
        _workingGroup = [];
        _undoStack = [];
        _redoStack = [];

        _undoButton.mouseEnabled = false;
        _redoButton.mouseEnabled = false;
    }

    protected var _workingGroup :Array; // of StrokeEvent
    protected var _undoStack :Array; // of [StrokeEvent]
    protected var _redoStack :Array; // of [StrokeEvent]

    protected var _undoButton :ImageButton;
    protected var _redoButton :ImageButton;

    [Embed(source="../../../res/undo.png")]
    protected static const ICON_UNDO :Class;
    [Embed(source="../../../res/redo.png")]
    protected static const ICON_REDO :Class;
}

}
