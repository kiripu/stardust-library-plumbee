package idv.cjcat.stardustextended.twoD.starling {

import flash.display.BitmapData;

import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.handlers.ParticleHandler;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.handlers.ISpriteSheetHandler;

import starling.display.DisplayObjectContainer;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

public class StarlingHandler extends ParticleHandler implements ISpriteSheetHandler{

    private var _blendMode:String;
    private var _bitmapData : BitmapData;
    private var _smoothing : String;
    private var _spriteSheetSliceWidth : uint;
    private var _spriteSheetSliceHeight : uint;
    private var _isSpriteSheet : Boolean;
    private var _spriteSheetAnimationSpeed : uint;
    private var _spriteSheetStartAtRandomFrame : Boolean;
    private var _totalFrames : uint;
    private var _texture : Texture;
    private var renderer : Stage3DRenderer;

    public function set container(container:DisplayObjectContainer) : void {
        if (renderer == null)
        {
            renderer = new Stage3DRenderer();
            renderer.blendMode = _blendMode;
            renderer.texSmoothing = _smoothing;
            calculateTexture();
        }
        container.addChild(renderer);
    }

    override public function stepEnd(emitter:Emitter, particles:Vector.<Particle>, time:Number):void {
        if (_isSpriteSheet)
        {
            // TODO take animation speed into account
            var mNumParticles:uint = particles.length;
            for (var i:int = 0; i < mNumParticles; ++i)
            {
                var particle : Particle = particles[i];
                var currFrame:int = particle.currentAnimationFrame;
                currFrame++;
                if (currFrame >= _totalFrames) {
                    currFrame = 0;
                }
                particle.currentAnimationFrame = currFrame;
            }
        }
        renderer.advanceTime(particles);
    }

    override public function particleAdded(particle:Particle):void {
        if (_isSpriteSheet)
        {
            var currFrame:uint = 0;
            if (_spriteSheetStartAtRandomFrame)
            {
                currFrame = Math.random() * _totalFrames;
            }
            particle.currentAnimationFrame = currFrame;
        }
        else
        {
            particle.currentAnimationFrame = 0;
        }
    }

    public function set bitmapData(bitmapData:BitmapData):void {
        _bitmapData = bitmapData;
        _spriteSheetSliceHeight = bitmapData.height;
        _spriteSheetSliceWidth = bitmapData.width;
        calculateTexture();
    }

    public function get bitmapData():BitmapData {
        return _bitmapData;
    }

    public function set spriteSheetSliceWidth(value:uint):void {
        _spriteSheetSliceWidth = value;
        calculateTexture();
    }

    public function get spriteSheetSliceWidth() : uint {
        return _spriteSheetSliceWidth;
    }

    public function set spriteSheetSliceHeight(value:uint):void {
        _spriteSheetSliceHeight = value;
        calculateTexture();
    }

    public function get spriteSheetSliceHeight() : uint {
        return _spriteSheetSliceHeight;
    }

    public function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:uint):void {
        _spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;
        calculateTexture();
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
        if (renderer)
        {
            renderer.texSmoothing = _smoothing;
        }
    }

    public function set blendMode(blendMode:String):void {
        _blendMode = blendMode;
        if (renderer)
        {
            renderer.blendMode = blendMode;
        }
    }

    public function get blendMode():String {
        return _blendMode;
    }

    private function calculateTexture() :void
    {
        if (renderer == null || _bitmapData == null)
        {
            return;
        }
        if (_texture)
        {
            _texture.dispose();
        }
        _texture = Texture.fromBitmapData(_bitmapData).root;

        _isSpriteSheet = (_spriteSheetSliceWidth > 0 && _spriteSheetSliceHeight > 0) &&
                         (_bitmapData.width >= _spriteSheetSliceWidth * 2 || _bitmapData.height >= _spriteSheetSliceHeight * 2);
        if (_isSpriteSheet)
        {
            _totalFrames = _spriteSheetAnimationSpeed * (_bitmapData.width / _spriteSheetSliceWidth  + _bitmapData.height / _spriteSheetSliceHeight - 1);
            const xIter : int = Math.floor( _bitmapData.width / _spriteSheetSliceWidth );
            const yIter : int = Math.floor( _bitmapData.height / _spriteSheetSliceHeight );
            const widthInTexCoords : Number = _spriteSheetSliceWidth / _texture.nativeWidth;
            const heightInTexCoords : Number = _spriteSheetSliceHeight / _texture.nativeHeight;
            var frames:Vector.<Frame> = new <Frame>[];
            for ( var j : int = 0; j < yIter; j++ )
            {
                for ( var i : int = 0; i < xIter; i++ )
                {
                    var frame : Frame = new Frame(
                            widthInTexCoords * i,
                            heightInTexCoords * j,
                            widthInTexCoords * (i + 1),
                            heightInTexCoords,
                            _spriteSheetSliceWidth/2,
                            _spriteSheetSliceHeight/2);
                    for (var k:int = 0; k < _spriteSheetAnimationSpeed; k++)
                    {
                        frames.push(frame);
                    }
                }
            }
            renderer.setTextures(_texture, frames);
        }
        else
        {
            _totalFrames = 1;
            renderer.setTextures(_texture, new <Frame>[new Frame(0, 0, 1, 1, _texture.width/2, _texture.height/2)]);
        }
    }

    //////////////////////////////////////////////////////// XML
    override public function getXMLTagName():String {
        return "StarlingHandler";
    }

    override public function toXML():XML {
        var xml:XML = super.toXML();
        xml.@imgWidth = _spriteSheetSliceWidth;
        xml.@imgHeight = _spriteSheetSliceHeight;
        xml.@animSpeed = _spriteSheetAnimationSpeed;
        xml.@startAtRandomFrame = _spriteSheetStartAtRandomFrame;
        xml.@smoothing = smoothing;
        xml.@blendMode = blendMode;
        return xml;
    }

    override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
        super.parseXML(xml, builder);
        spriteSheetSliceWidth = xml.@imgWidth;
        spriteSheetSliceHeight = xml.@imgHeight;
        spriteSheetAnimationSpeed = xml.@animSpeed;
        spriteSheetStartAtRandomFrame = (xml.@startAtRandomFrame == "true");
        smoothing = (xml.@smoothing == "true");
        if (xml.@blendMode.length()) blendMode = (xml.@blendMode);
    }

}
}
