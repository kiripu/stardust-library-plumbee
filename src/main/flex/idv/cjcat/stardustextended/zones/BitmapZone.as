package idv.cjcat.stardustextended.zones
{

import flash.display.BitmapData;
import flash.utils.ByteArray;

import idv.cjcat.stardustextended.geom.MotionData2D;
import idv.cjcat.stardustextended.geom.MotionData2DPool;

/**
 * Zone formed by a bitmap's non-transparent pixels.
 */
public class BitmapZone extends Zone
{

    /**
     * The horizontal scale of the bitmap.
     */
    public var scaleX : Number;
    /**
     * The vertical scale of the bitmap.
     */
    public var scaleY : Number;

    private var xCoords : Array;
    private var yCoords : Array;

    public function BitmapZone(bitmapData : BitmapData = null, x : Number = 0, y : Number = 0, scaleX : Number = 1, scaleY : Number = 1)
    {
        this.x = x;
        this.y = y;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        xCoords = [];
        yCoords = [];
        update(bitmapData);
    }

    private var bmpd : BitmapData;
    private var coordLength : int;

    public function update(bitmapData : BitmapData = null) : void
    {
        if (!bitmapData) bitmapData = new BitmapData(1, 1, true, 0xFF808080);

        bmpd = bitmapData.clone();

        var ba : ByteArray = bitmapData.getPixels(bitmapData.rect);
        var len : int = ba.length >> 2;
        xCoords.length = yCoords.length = len;

        var xPos : int = 0;
        var yPos : int = 0;
        coordLength = 0;
        for (var i : int = 0; i < len; i++) {
            if (ba[i * 4] > 0) {
                xCoords[coordLength] = xPos;
                yCoords[coordLength] = yPos;
                coordLength++;
            }
            xPos++;
            if (xPos == bitmapData.width) {
                xPos = 0;
                yPos++;
            }
        }
    }

    override public function contains(x : Number, y : Number) : Boolean
    {
        x = int(x + 0.5);
        y = int(y + 0.5);
        if (uint(bmpd.getPixel32(x, y) >> 24)) return true;
        return false;
    }

    override public function calculateMotionData2D() : MotionData2D
    {
        if (xCoords.length == 0) return MotionData2DPool.get(0, 0);
        var index : int = int(coordLength * Math.random());
        return MotionData2DPool.get(xCoords[index] * scaleX, yCoords[index] * scaleY);
    }



}
}