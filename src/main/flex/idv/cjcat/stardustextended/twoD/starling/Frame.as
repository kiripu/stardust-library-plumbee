package idv.cjcat.stardustextended.twoD.starling {

public class Frame {

    public var particleHalfWidth:Number = 1.0;
    public var particleHalfHeight:Number = 1.0;
    public var textureX:Number = 0.0;
    public var textureY:Number = 0.0;
    public var textureWidth:Number = 1.0;
    public var textureHeight:Number = 1.0;

    public function Frame(x:Number,
                          y:Number,
                          width:Number,
                          height:Number,
                          halfWidth:Number,
                          halfHeight:Number)
    {
        textureX = x;
        textureY = y;
        textureWidth = width;
        textureHeight = height;
        particleHalfWidth = halfWidth;
        particleHalfHeight = halfHeight;

        /*
        textureX = x / nativeTextureWidth;
        textureY = y / nativeTextureHeight;
        textureWidth = (x + width) / nativeTextureWidth;
        textureHeight = (y + height) / nativeTextureHeight;
        particleHalfWidth = (width) >> 1;
        particleHalfHeight = (height) >> 1;
        */
    }
}
}
