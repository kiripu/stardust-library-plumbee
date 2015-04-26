package idv.cjcat.stardustextended.twoD.starling {

import flash.display.BitmapData;

import idv.cjcat.stardustextended.common.emitters.Emitter;
import idv.cjcat.stardustextended.common.handlers.ParticleHandler;
import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.common.xml.XMLBuilder;
import idv.cjcat.stardustextended.twoD.handlers.ISpriteSheetHandler;

import starling.display.BlendMode;

import starling.display.DisplayObjectContainer;
import starling.textures.SubTexture;
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
    private var _premultiplyAlpha : Boolean = true;
    private var _spriteSheetStartAtRandomFrame : Boolean;
    private var _totalFrames : uint;
    private var _texture : Texture;
    private var _renderer : StardustStarlingRenderer;

    public function set container(container:DisplayObjectContainer) : void
    {
        createRendererIfNeeded();
        container.addChild(_renderer);
    }

    private function createRendererIfNeeded() : void
    {
        if (_renderer == null)
        {
            _renderer = new StardustStarlingRenderer();
            _renderer.blendMode = _blendMode;
            _renderer.texSmoothing = _smoothing;
            _renderer.premultiplyAlpha = _premultiplyAlpha;
        }
    }

    override public function stepEnd(emitter:Emitter, particles:Vector.<Particle>, time:Number):void {
        if (_isSpriteSheet && _spriteSheetAnimationSpeed > 0)
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

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
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
        _texture = Texture.fromBitmapData(_bitmapData);
    }

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    public function get texture():Texture
    {
        return _texture;
    }

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    public function get bitmapData():BitmapData {
        return _bitmapData;
    }

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    public function set spriteSheetSliceWidth(value:uint):void {
        _spriteSheetSliceWidth = value;
    }

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    public function get spriteSheetSliceWidth() : uint {
        return _spriteSheetSliceWidth;
    }

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    public function set spriteSheetSliceHeight(value:uint):void {
        _spriteSheetSliceHeight = value;
    }

    [Deprecated(message="This property will be soon removed, use setTextures() instead")]
    public function get spriteSheetSliceHeight() : uint {
        return _spriteSheetSliceHeight;
    }

    public function set spriteSheetAnimationSpeed(spriteSheetAnimationSpeed:uint):void {
        _spriteSheetAnimationSpeed = spriteSheetAnimationSpeed;
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
        createRendererIfNeeded();
        _renderer.texSmoothing = _smoothing;
    }

    public function get premultiplyAlpha():Boolean {
        return _premultiplyAlpha;
    }

    public function set premultiplyAlpha(value:Boolean):void {
        _premultiplyAlpha = value;
        createRendererIfNeeded();
        _renderer.premultiplyAlpha = value;
    }

    public function set blendMode(blendMode:String):void
    {
        _blendMode = blendMode;
        createRendererIfNeeded();
        _renderer.blendMode = blendMode;
    }

    public function get blendMode():String
    {
        return _blendMode;
    }

    /** Sets the textures directly. Stardust can batch the simulations resulting multiple simulations using
     *  just one draw call. To have this working the following must be met:
     *  - The textures must come from the same sprite sheet. (= they must have the same base texture)
     *  - The simulations must have the same render target, tinted, smoothing, blendMode, same filter (if any)
     *    and the same premultiplyAlpha values.
     **/
    public function setTextures(textures : Vector.<SubTexture>):void
    {
        createRendererIfNeeded();
        _isSpriteSheet = textures.length > 1;
        var frames:Vector.<Frame> = new <Frame>[];
        for each (var texture:SubTexture in textures)
        {
            if (texture.root != textures[0].root)
            {
                throw new Error("The texture " + texture + " does not share the same base root with others");
            }
            // TODO: use the transformationMatrix
            var frame : Frame = new Frame(
                    texture.region.x / texture.root.width,
                    texture.region.y / texture.root.height,
                    (texture.region.x + texture.region.width) / texture.root.width,
                    (texture.region.y + texture.region.height)/ texture.root.height,
                    texture.width * 0.5,
                    texture.height * 0.5);
            var numFrames : uint = _spriteSheetAnimationSpeed;
            if (numFrames == 0)
            {
                numFrames = 1; // if animation speed is 0, add each frame once
            }
            for (var k:int = 0; k < numFrames; k++)
            {
                frames.push(frame);
            }
        }
        _renderer.setTextures(textures[0].root, frames);
    }

    public function get renderer():StardustStarlingRenderer
    {
        return _renderer;
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
        xml.@premultiplyAlpha = _premultiplyAlpha;
        return xml;
    }

    override public function parseXML(xml:XML, builder:XMLBuilder = null):void {
        super.parseXML(xml, builder);
        _spriteSheetSliceWidth = xml.@spriteSheetSliceWidth;
        _spriteSheetSliceHeight = xml.@spriteSheetSliceHeight;
        _spriteSheetAnimationSpeed = xml.@spriteSheetAnimationSpeed;
        _spriteSheetStartAtRandomFrame = (xml.@spriteSheetStartAtRandomFrame == "true");
        smoothing = (xml.@smoothing == "true");
        blendMode = (xml.@blendMode);
        if (xml.@premultiplyAlpha.length()) premultiplyAlpha = (xml.@premultiplyAlpha == "true");
    }

}
}
