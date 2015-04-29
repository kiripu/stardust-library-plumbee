package idv.cjcat.stardustextended.twoD.handlers {

public interface ISpriteSheetHandler {


    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    function set spriteSheetSliceWidth(value:uint):void

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    function get spriteSheetSliceWidth() : uint

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    function set spriteSheetSliceHeight(value:uint):void

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    function get spriteSheetSliceHeight() : uint

    function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:uint):void;

    function get spriteSheetAnimationSpeed():uint;

    function set spriteSheetStartAtRandomFrame(spriteSheetStartAtRandomFrame:Boolean):void;

    function get spriteSheetStartAtRandomFrame():Boolean;

    function get smoothing():Boolean;

    function set smoothing(value:Boolean):void;

    function get isSpriteSheet():Boolean;

    function set blendMode(blendMode:String):void;

    function get blendMode():String;
}
}
