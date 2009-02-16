package scribble.client {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.ColorMatrixFilter;

public class ImageButton extends Sprite
{
    public function ImageButton (image :Bitmap)
    {
        _image = image;
        addChild(_image);

        addEventListener(MouseEvent.ROLL_OVER, function (... _) :void {
            _hovering = true;
            update();
        });
        addEventListener(MouseEvent.ROLL_OUT, function (... _) :void {
            _hovering = false;
            update();
            _image.y = 0;
        });

        addEventListener(MouseEvent.MOUSE_DOWN, function (... _) :void {
            _image.y = 2;
        });
        addEventListener(MouseEvent.MOUSE_UP, function (... _) :void {
            _image.y = 0;
        });
    }

    public override function set mouseEnabled (enabled :Boolean) :void
    {
        super.mouseEnabled = enabled;

        update();
    }

    protected function update () :void
    {
        if (mouseEnabled) {
            if (_hovering) {
                _image.filters = BRIGHTEN;
            } else {
                _image.filters = null;
            }
        } else {
            _image.filters = DESATURATE;
            _image.y = 0;
        }
    }

    protected static const DESATURATE :Array = [ new ColorMatrixFilter([
        1/3, 1/3, 1/3, 0, 0,
        1/3, 1/3, 1/3, 0, 0,
        1/3, 1/3, 1/3, 0, 0,
        0, 0, 0, 1, 0
    ]) ];

    protected static const BRIGHTEN :Array = [ new ColorMatrixFilter([
        1.25, 0, 0, 0, 0,
        0, 1.25, 0, 0, 0,
        0, 0, 1.25, 0, 0,
        0, 0, 0, 1, 0
    ]) ];

    protected var _image :Bitmap;
    protected var _hovering :Boolean;
}

}
