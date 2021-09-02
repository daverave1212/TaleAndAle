
import openfl.display.BitmapData;
import Std.int;

class PanelVerticable extends Positionable{

    public var imageTop: ImageX;
    public var imageMiddle: ImageX;
    public var imageBottom: ImageX;
    public var lastRecalculatedHeight: Float = 0;

    public function new(topBitmap: BitmapData, middleBitmap: BitmapData, bottomBitmap: BitmapData, layerName: String) {
        imageTop = new ImageX(topBitmap, layerName);
        imageMiddle = new ImageX(middleBitmap, layerName);
        imageBottom = new ImageX(bottomBitmap, layerName);
    }

    public function setMiddleHeight(newMiddleHeight: Int) {
        imageMiddle.setHeight(newMiddleHeight);
        recalculatePositionFromTop();
    }
    public function getMiddleY() return imageMiddle.getY();
    public function getBottomY() return imageBottom.getY();
    public function setHeight(newHeight: Int) {
        lastRecalculatedHeight = newHeight;
        var newMiddleHeight = newHeight - imageTop.getHeight() - imageBottom.getHeight();
        if (newMiddleHeight <= 0)
            newMiddleHeight = 0;
        setMiddleHeight(int(newMiddleHeight));
    }

    public function recalculatePositionFromTop() {
        imageMiddle.setX(imageTop.getX());
        imageMiddle.setY(imageTop.getY() + imageTop.getHeight());
        imageBottom.setX(imageTop.getX());
        imageBottom.setY(imageMiddle.getY() + imageMiddle.getHeight());
    }

    public override function setX(newX: Float) {
        imageTop.setX(int(newX));
        recalculatePositionFromTop();
    }
    public override function setY(newY: Float) {
        imageTop.setY(int(newY));
        recalculatePositionFromTop();
    }
    public override function centerHorizontally() {
        imageTop.centerHorizontally();
        recalculatePositionFromTop();
        return this;
    }
    public override function centerVertically() {
        imageMiddle.centerVertically();
        imageTop.setY(imageMiddle.getY() - imageTop.getHeight());
        imageBottom.setY(imageMiddle.getY() + imageMiddle.getHeight());
        return this;
    }

    public override function getX(): Float return imageTop.getX();
    public override function getY(): Float return imageTop.getY();
    public override function getWidth() return imageTop.getWidth();
    public override function getHeight() return lastRecalculatedHeight;
    public function hide() {
        imageTop.hide();
        imageMiddle.hide();
        imageBottom.hide();
    }
    public function show() {
        imageTop.show();
        imageMiddle.show();
        imageBottom.show();
    }

}
