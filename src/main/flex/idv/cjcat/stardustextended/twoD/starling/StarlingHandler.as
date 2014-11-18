package idv.cjcat.stardustextended.twoD.starling {

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.handlers.ParticleHandler;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.twoD.handlers.DisplayObjectSpriteSheetHandler;
import idv.cjcat.stardustextended.twoD.handlers.ISpriteSheetHandler;
import idv.cjcat.stardustextended.twoD.particles.Particle2D;

import starling.display.DisplayObjectContainer;
import starling.display.Image;

import starling.display.QuadBatch;
import starling.textures.SubTexture;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

public class StarlingHandler extends ParticleHandler implements ISpriteSheetHandler{

    private var _blendMode:String;
    private var _bitmapData : BitmapData;
    private var _batch:QuadBatch;
    private var _smoothing : String;
    private var image:Image;
    private var _spriteSheetSliceWidth : uint;
    private var _spriteSheetSliceHeight : uint;
    private var _isSpriteSheet : Boolean;
    private var _spriteSheetAnimationSpeed : uint;
    private var _spriteSheetStartAtRandomFrame : Boolean;
    private var _totalFrames : uint;

    private var renderer : Stage3DRenderer;
    private static const DEGREES_TO_RADIANS : Number = Math.PI / 180;

    public function set container(container:DisplayObjectContainer) : void {

        /*if (_batch == null) {
            _batch = new QuadBatch();
        }
        if (_batch.parent) {
            _batch.parent.removeChild(_batch);
        }
        container.addChild(_batch);
        */

        if (renderer == null)
        {
            renderer = new Stage3DRenderer();
        }
        container.addChild(renderer);
    }

    override public function stepEnd(emitter:Emitter, particles:Vector.<Particle>, time:Number):void {
        renderer.advanceTime(particles, image.texture);
        /*
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

            //if (_isSpriteSheet)
            //{
            //    var currFrame : uint = particle.dictionary[DisplayObjectSpriteSheetHandler.CURRENT_FRAME];
            //    const nextFrame : uint = (currFrame + time) % _totalFrames;
            //    const nextImageIndex : uint = uint(nextFrame / _spriteSheetAnimationSpeed);
            //    const currImageIndex : uint = uint(currFrame / _spriteSheetAnimationSpeed);
            //    if ( nextImageIndex != currImageIndex )
            //    {

            //    }
            //    particle.dictionary[DisplayObjectSpriteSheetHandler.CURRENT_FRAME] = nextFrame;
            //}
            _batch.addQuad(image, 1, image.texture, _smoothing, null, _blendMode);
        }
        */
    }

    override public function particleAdded(particle:Particle):void {
        particle.color = 0xFFFFFF;
        if (_isSpriteSheet)
        {
            var currFrame:uint = 0;
            if (_spriteSheetStartAtRandomFrame)
            {
                currFrame = Math.random() * _totalFrames;
            }
            particle.currentAnimationFrame = currFrame;
        }
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

    public function set spriteSheetSliceWidth(value:uint):void {
        _spriteSheetSliceWidth = value;
        calculateSpriteSheetProperties();
    }

    public function get spriteSheetSliceWidth() : uint {
        return _spriteSheetSliceWidth;
    }

    public function set spriteSheetSliceHeight(value:uint):void {
        _spriteSheetSliceHeight = value;
        calculateSpriteSheetProperties();
    }

    public function get spriteSheetSliceHeight() : uint {
        return _spriteSheetSliceHeight;
    }

    public function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:uint):void {
        _spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;
        calculateSpriteSheetProperties();
    }

    public function get spriteSheetAnimationSpeed():uint {
        return _spriteSheetAnimationSpeed;
    }

    public function set spriteSheetStartAtRandomFrame(spriteSheetStartAtRandomFrame:Boolean):void {
        _spriteSheetStartAtRandomFrame = spriteSheetStartAtRandomFrame;
    }

    public function get spriteSheetStartAtRandomFrame():Boolean {
        return _spriteSheetStartAtRandomFrame;
    }

    public function get isSpriteSheet():Boolean {
        return _isSpriteSheet;
    }

    public function get smoothing():Boolean {
        return _smoothing != TextureSmoothing.NONE;
    }

    public function set smoothing(value:Boolean):void {
        if (value == true) {
            _smoothing = TextureSmoothing.BILINEAR;
        }
        else {
            _smoothing = TextureSmoothing.NONE;
        }
    }

    public function set blendMode(blendMode:String):void {
        _blendMode = blendMode;
    }

    public function get blendMode():String {
        return _blendMode;
    }

    private function calculateSpriteSheetProperties() :void
    {
        if (_bitmapData == null || _spriteSheetSliceWidth == 0 || _spriteSheetSliceHeight == 0)
        {
            return;
        }
        _isSpriteSheet = _bitmapData.width > _spriteSheetSliceWidth || _bitmapData.height > _spriteSheetSliceHeight;
        if (_isSpriteSheet)
        {
            _totalFrames = _spriteSheetAnimationSpeed * (_bitmapData.width / _spriteSheetSliceWidth  + _bitmapData.height / _spriteSheetSliceHeight);
        }
    }

    //////////////////////////////////////////////////////// XML
    override public function getXMLTagName():String {
        return "StarlingHandler";
    }

}
}
