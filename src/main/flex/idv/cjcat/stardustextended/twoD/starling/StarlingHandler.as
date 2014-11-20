package idv.cjcat.stardustextended.twoD.starling {

import flash.display.BitmapData;

import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.handlers.ParticleHandler;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.handlers.ISpriteSheetHandler;

import starling.display.BlendMode;

import starling.display.DisplayObjectContainer;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;

public class StarlingHandler extends ParticleHandler implements ISpriteSheetHandler{

    private var _blendMode:String = BlendMode.NORMAL;
    private var _spriteSheetSliceWidth : uint = 32;
    private var _spriteSheetSliceHeight : uint = 32;
    private var _spriteSheetAnimationSpeed : uint = 1;
    private var _bitmapData : BitmapData;
    private var _smoothing : String;
    private var _isSpriteSheet : Boolean;
    private var _spriteSheetStartAtRandomFrame : Boolean;
    private var _totalFrames : uint;
    private var _texture : Texture;
    private var _renderer : Stage3DRenderer;

    public function set container(container:DisplayObjectContainer) : void {
        if (_renderer == null)
        {
            _renderer = new Stage3DRenderer();
            _renderer.blendMode = _blendMode;
            _renderer.texSmoothing = _smoothing;
            calculateTextureCoordinates();
        }
        container.addChild(_renderer);
    }

    override public function stepEnd(emitter:Emitter, particles:Vector.<Particle>, time:Number):void {
        if (_isSpriteSheet)
        {
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
        _renderer.advanceTime(particles);
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
        if (_bitmapData == null)
        {
            return;
        }
        if (_spriteSheetSliceHeight > bitmapData.height)
        {
            _spriteSheetSliceHeight = bitmapData.height;
        }
        if (_spriteSheetSliceWidth > bitmapData.width)
        {
            _spriteSheetSliceWidth = bitmapData.width;
        }
        _texture = Texture.fromBitmapData(_bitmapData).root;
        calculateTextureCoordinates();
    }

    public function get bitmapData():BitmapData {
        return _bitmapData;
    }

    public function set spriteSheetSliceWidth(value:uint):void {
        _spriteSheetSliceWidth = value;
        calculateTextureCoordinates();
    }

    public function get spriteSheetSliceWidth() : uint {
        return _spriteSheetSliceWidth;
    }

    public function set spriteSheetSliceHeight(value:uint):void {
        _spriteSheetSliceHeight = value;
        calculateTextureCoordinates();
    }

    public function get spriteSheetSliceHeight() : uint {
        return _spriteSheetSliceHeight;
    }

    public function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:uint):void {
        _spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;
        calculateTextureCoordinates();
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
        if (_renderer)
        {
            _renderer.texSmoothing = _smoothing;
        }
    }

    public function set blendMode(blendMode:String):void
    {
        _blendMode = blendMode;
        if (_renderer)
        {
            _renderer.blendMode = blendMode;
        }
    }

    public function get blendMode():String
    {
        return _blendMode;
    }

    public function get texture():Texture
    {
        return _texture;
    }

    /** Set the texture directly. Texture atlases are not properly supported since the sprites must begin
     * at (0,0) in the texture and they must come after each other. */
    public function set texture(value:Texture):void
    {
        _texture = value;
    }

    public function get renderer():Stage3DRenderer
    {
        return _renderer;
    }

    private function calculateTextureCoordinates() :void
    {
        if (_renderer == null || _bitmapData == null)
        {
            return;
        }
        _isSpriteSheet = (_spriteSheetSliceWidth > 0 && _spriteSheetSliceHeight > 0) &&
                         (_bitmapData.width >= _spriteSheetSliceWidth * 2 || _bitmapData.height >= _spriteSheetSliceHeight * 2);
        if (_isSpriteSheet)
        {
            _totalFrames = _spriteSheetAnimationSpeed * (_bitmapData.width / _spriteSheetSliceWidth  + _bitmapData.height / _spriteSheetSliceHeight - 1);
            const xIter : int = Math.floor( _bitmapData.width / _spriteSheetSliceWidth );
            const yIter : int = Math.floor( _bitmapData.height / _spriteSheetSliceHeight );
            const xInTexCoords : Number = _spriteSheetSliceWidth / _texture.nativeWidth;
            const yInTexCoords : Number = _spriteSheetSliceHeight / _texture.nativeHeight;
            var frames:Vector.<Frame> = new <Frame>[];
            for ( var j : int = 0; j < yIter; j++ )
            {
                for ( var i : int = 0; i < xIter; i++ )
                {
                    var frame : Frame = new Frame(
                            xInTexCoords * i,
                            yInTexCoords * j,
                            xInTexCoords * (i + 1),
                            yInTexCoords * (j + 1),
                            _spriteSheetSliceWidth/2,
                            _spriteSheetSliceHeight/2);
                    for (var k:int = 0; k < _spriteSheetAnimationSpeed; k++)
                    {
                        frames.push(frame);
                    }
                }
            }
            _renderer.setTextures(_texture, frames);
        }
        else
        {
            _totalFrames = 1;
            _renderer.setTextures(_texture, new <Frame>[new Frame(0, 0, 1, 1, _texture.width/2, _texture.height/2)]);
        }
    }

    //////////////////////////////////////////////////////// XML
    override public function getXMLTagName():String {
        return "StarlingHandler";
    }

    override public function toXML():XML {
        var xml:XML = super.toXML();
        xml.@spriteSheetSliceWidth = _spriteSheetSliceWidth;
        xml.@spriteSheetSliceHeight = _spriteSheetSliceHeight;
        xml.@spriteSheetAnimationSpeed = _spriteSheetAnimationSpeed;
        xml.@spriteSheetStartAtRandomFrame = _spriteSheetStartAtRandomFrame;
        xml.@smoothing = smoothing;
        xml.@blendMode = _blendMode;
        return xml;
    }

    override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
        super.parseXML(xml, builder);
        _spriteSheetSliceWidth = xml.@spriteSheetSliceWidth;
        _spriteSheetSliceHeight = xml.@spriteSheetSliceHeight;
        _spriteSheetAnimationSpeed = xml.@spriteSheetAnimationSpeed;
        _spriteSheetStartAtRandomFrame = (xml.@spriteSheetStartAtRandomFrame == "true");
        smoothing = (xml.@smoothing == "true");
        _blendMode = (xml.@blendMode);
        calculateTextureCoordinates();
    }

}
}
