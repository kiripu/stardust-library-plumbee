package idv.cjcat.stardustextended.twoD.starling {

import flash.display.BitmapData;

import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.handlers.ParticleHandler;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.twoD.handlers.ISpriteSheetHandler;
import idv.cjcat.stardustextended.twoD.particles.Particle2D;

import starling.display.DisplayObjectContainer;
import starling.display.Image;

import starling.display.QuadBatch;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

public class StarlingHandler extends ParticleHandler implements ISpriteSheetHandler{

    private var _blendMode:String;
    private var _bitmapData : BitmapData;
    private var _batch:QuadBatch;
    private var _smoothing : String;
    private var image:Image;

    private static const DEGREES_TO_RADIANS : Number = Math.PI / 180;

    public function set container(container:DisplayObjectContainer) : void {
        if (_batch == null) {
            _batch = new QuadBatch();
        }
        if (_batch.parent) {
            _batch.parent.removeChild(_batch);
        }
        container.addChild(_batch);
    }

    override public function stepEnd(emitter:Emitter, particles:Vector.<Particle>, time:Number):void {
        _batch.reset();
        for (var i:int = 0; i < particles.length; i++) {
            var particle : Particle2D = Particle2D(particles[i]);
            image.x = particle.x;
            image.y = particle.y;
            image.scaleX = image.scaleY = particle.scale;
            if (image.rotation != particle.rotation * DEGREES_TO_RADIANS)
            {
                image.rotation = particle.rotation * DEGREES_TO_RADIANS;
            }
            if (image.alpha != particle.alpha)
            {
                image.alpha = particle.alpha;
            }
            if (image.color != particle.color)
            {
                image.color = particle.color;
            }
            _batch.addQuad(image, 1, image.texture, _smoothing, null, _blendMode);
        }
    }

    override public function particleAdded(particle:Particle):void {
        particle.color = 0xFFFFFF;
    }

    public function set bitmapData(bitmapData:BitmapData):void {
        _bitmapData = bitmapData;
        image = new Image( Texture.fromBitmapData(_bitmapData) );
        image.pivotX = image.width * 0.5;
        image.pivotY = image.height * 0.5;
    }

    public function get bitmapData():BitmapData {
        return _bitmapData;
    }

    // Todo
    public function set spriteSheetSliceWidth(value:uint):void {
    }

    public function get spriteSheetSliceWidth():uint {
        return 0;
    }

    public function set spriteSheetSliceHeight(value:uint):void {
    }

    public function get spriteSheetSliceHeight():uint {
        return 0;
    }

    public function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:uint):void {
    }

    public function get spriteSheetAnimationSpeed():uint {
        return 0;
    }

    public function set spriteSheetStartAtRandomFrame(spriteSheetStartAtRandomFrame:Boolean):void {
    }

    public function get spriteSheetStartAtRandomFrame():Boolean {
        return false;
    }

    public function get smoothing():Boolean {
        return _smoothing != TextureSmoothing.NONE;
    }

    public function set smoothing(value:Boolean):void {
        if (value == true) {
            _smoothing = TextureSmoothing.TRILINEAR
        }
        else {
            _smoothing = TextureSmoothing.NONE;
        }
    }

    public function get isSpriteSheet():Boolean {
        return false;
    }

    public function set blendMode(blendMode:String):void {
        _blendMode = blendMode;
    }

    public function get blendMode():String {
        return _blendMode;
    }

    //////////////////////////////////////////////////////// XML
    override public function getXMLTagName():String {
        return "StarlingHandler";
    }

}
}
