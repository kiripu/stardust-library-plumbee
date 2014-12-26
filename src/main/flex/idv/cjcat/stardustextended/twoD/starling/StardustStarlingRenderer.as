package idv.cjcat.stardustextended.twoD.starling {

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.textures.TextureBase;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;

import idv.cjcat.stardustextended.common.particles.Particle;

import idv.cjcat.stardustextended.twoD.particles.Particle2D;

import starling.core.RenderSupport;
import starling.core.Starling;
import starling.display.BlendMode;

import starling.display.DisplayObject;
import starling.errors.MissingContextError;
import starling.filters.FragmentFilter;
import starling.textures.Texture;
import starling.utils.MatrixUtil;
import starling.utils.VertexData;

public class StardustStarlingRenderer extends DisplayObject
{
    public static var MAX_PARTICLES:int = 16383;
    private static const DEGREES_TO_RADIANS : Number = Math.PI / 180;
    private static const sCosLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
    private static const sSinLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
    private static var numberOfVertexBuffers:int;
    private static var sLUTsCreated:Boolean = false;
    
    private var boundsRect : Rectangle;
    private var mFilter:FragmentFilter;
    private var mTinted : Boolean = true;
    private var mTexture : Texture;
    private var mBatched : Boolean;
    private var vertexes:Vector.<Number>;
    private var frames : Vector.<Frame>;

    public var mNumParticles:int = 0;
    public var texSmoothing : String;

    public function StardustStarlingRenderer()
    {
        if (StarlingParticleBuffers.buffersCreated == false)
        {
            init();
        }
        vertexes = new <Number>[];
    }

    /** numberOfBuffers is the amount of vertex buffers used by the particle system for multi buffering. Multi buffering
     *  can avoid stalling of the GPU but will also increases it's memory consumption.
     *  This call requires that there is a Starling context
     *  */
    public static function init(numberOfBuffers:uint = 2):void
    {
        numberOfVertexBuffers = numberOfBuffers;
        StarlingParticleBuffers.createBuffers(MAX_PARTICLES, numberOfBuffers);

        if (!sLUTsCreated)
        {
            for (var i:int = 0; i < 0x800; ++i)
            {
                sCosLUT[i & 0x7FF] = Math.cos(i * 0.00306796157577128245943617517898); // 0.003067 = 2PI/2048
                sSinLUT[i & 0x7FF] = Math.sin(i * 0.00306796157577128245943617517898);
            }
            sLUTsCreated = true
        }
        // handle a lost device context
        Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true);
    }

    private static function onContextCreated(event:Event):void
    {
        StarlingParticleBuffers.createBuffers(MAX_PARTICLES, numberOfVertexBuffers);
    }

    /** Set to true if any of the rendered particles have alpha value. Default is true, setting it to false
     *  decreases load on the GPU, but particles will be rendered with 1 alpha. */
    public function set tinted(value:Boolean):void {
        mTinted = value;
    }

    public function setTextures(texture: Texture, _frames:Vector.<Frame>):void
    {
        mTexture = texture;
        frames = _frames;
    }

    public function advanceTime(mParticles : Vector.<Particle>):void
    {
        mNumParticles = mParticles.length;
        var particle:Particle2D;
        var vertexID:int = 0;

        var red:Number;
        var green:Number;
        var blue:Number;
        var particleAlpha:Number;

        var rotation:Number;
        var x:Number, y:Number;
        var xOffset:Number, yOffset:Number;

        var angle:uint;
        var cos:Number;
        var sin:Number;
        var cosX:Number;
        var cosY:Number;
        var sinX:Number;
        var sinY:Number;
        var position:uint;
        var frame : Frame;
        var bottomRightX : Number;
        var bottomRightY : Number;
        var topLeftX : Number;
        var topLeftY : Number;

        for (var i:int = 0; i < mNumParticles; ++i)
        {
            vertexID = i << 2;
            particle = Particle2D(mParticles[i]);
            // color & alpha
            particleAlpha = particle.alpha;
            red = particle.colorR * particleAlpha; // premultiply alpha
            green = particle.colorG * particleAlpha;
            blue = particle.colorB * particleAlpha;

            // position & rotation
            rotation = particle.rotation * DEGREES_TO_RADIANS;
            x = particle.x;
            y = particle.y;
            // texture
            frame = frames[particle.currentAnimationFrame];
            bottomRightX = frame.bottomRightX;
            bottomRightY = frame.bottomRightY;
            topLeftX = frame.topLeftX;
            topLeftY = frame.topLeftY;
            xOffset = frame.particleHalfWidth * particle.scale;
            yOffset = frame.particleHalfHeight * particle.scale;

            position = vertexID << 3; // * 8
            if (rotation)
            {
                angle = (rotation * 325.94932345220164765467394738691) & 2047;
                cos = sCosLUT[angle];
                sin = sSinLUT[angle];
                cosX = cos * xOffset;
                cosY = cos * yOffset;
                sinX = sin * xOffset;
                sinY = sin * yOffset;

                vertexes[position] = x - cosX + sinY;  // 0,1: position (in pixels)
                vertexes[++position] = y - sinX - cosY;
                vertexes[++position] = red;// 2,3,4,5: Color and Alpha [0-1]
                vertexes[++position] = green;
                vertexes[++position] = blue;
                vertexes[++position] = particleAlpha;
                vertexes[++position] = topLeftX; // 6,7: Texture coords [0-1]
                vertexes[++position] = topLeftY;

                vertexes[++position] = x + cosX + sinY;
                vertexes[++position] = y + sinX - cosY;
                vertexes[++position] = red;
                vertexes[++position] = green;
                vertexes[++position] = blue;
                vertexes[++position] = particleAlpha;
                vertexes[++position] = bottomRightX;
                vertexes[++position] = topLeftY;

                vertexes[++position] = x - cosX - sinY;
                vertexes[++position] = y - sinX + cosY;
                vertexes[++position] = red;
                vertexes[++position] = green;
                vertexes[++position] = blue;
                vertexes[++position] = particleAlpha;
                vertexes[++position] = topLeftX;
                vertexes[++position] = bottomRightY;

                vertexes[++position] = x + cosX - sinY;
                vertexes[++position] = y + sinX + cosY;
                vertexes[++position] = red;
                vertexes[++position] = green;
                vertexes[++position] = blue;
                vertexes[++position] = particleAlpha;
                vertexes[++position] = bottomRightX;
                vertexes[++position] = bottomRightY;
            }
            else
            {
                vertexes[position] = x - xOffset;
                vertexes[++position] = y - yOffset;
                vertexes[++position] = red;
                vertexes[++position] = green;
                vertexes[++position] = blue;
                vertexes[++position] = particleAlpha;
                vertexes[++position] = topLeftX;
                vertexes[++position] = topLeftY;

                vertexes[++position] = x + xOffset;
                vertexes[++position] = y - yOffset;
                vertexes[++position] = red;
                vertexes[++position] = green;
                vertexes[++position] = blue;
                vertexes[++position] = particleAlpha;
                vertexes[++position] = bottomRightX;
                vertexes[++position] = topLeftY;

                vertexes[++position] = x - xOffset;
                vertexes[++position] = y + yOffset;
                vertexes[++position] = red;
                vertexes[++position] = green;
                vertexes[++position] = blue;
                vertexes[++position] = particleAlpha;
                vertexes[++position] = topLeftX;
                vertexes[++position] = bottomRightY;

                vertexes[++position] = x + xOffset;
                vertexes[++position] = y + yOffset;
                vertexes[++position] = red;
                vertexes[++position] = green;
                vertexes[++position] = blue;
                vertexes[++position] = particleAlpha;
                vertexes[++position] = bottomRightX;
                vertexes[++position] = bottomRightY;
            }
        }
    }

    public function isStateChange(tinted:Boolean, parentAlpha:Number, texture:TextureBase, textureRepeat:Boolean,
                                  smoothing:String, blendMode:String, blendFactorSource:String,
                                  blendFactorDestination:String, filter:FragmentFilter):Boolean
    {
        if (mNumParticles == 0)
        {
            return false;
        }
        else if (mTexture != null && texture != null)
        {
            var blendFactors:Array = BlendMode.getBlendFactors(blendMode, true);
            return mTexture.base != texture || mTexture.repeat != textureRepeat ||
                   texSmoothing != smoothing || mTinted != (tinted || parentAlpha != 1.0) ||
                   this.blendMode != blendMode || blendFactors[0] != blendFactorSource ||
                    blendFactors[1] != blendFactorDestination || mFilter != filter;
        }
        return true;
    }

    public override function render(support:RenderSupport, parentAlpha:Number):void
    {
        if (mNumParticles > 0 && !mBatched)
        {
            var mNumBatchedParticles : int = batchNeighbours();
            renderCustom(support, mNumBatchedParticles, parentAlpha);
        }
        //reset filter
        super.filter = mFilter;
        mBatched = false;
    }

    private function batchNeighbours() : int
    {
        var mNumBatchedParticles : int = 0;
        var last:int = parent.getChildIndex(this);

        while (++last < parent.numChildren)
        {
            var blendFactors:Array = BlendMode.getBlendFactors(blendMode, true);
            var nextPS:StardustStarlingRenderer = parent.getChildAt(last) as StardustStarlingRenderer;
            if (nextPS != null && nextPS.mNumParticles > 0 &&
                !nextPS.isStateChange(mTinted, alpha, mTexture.base, mTexture.repeat, texSmoothing, blendMode, blendFactors[0], blendFactors[1], mFilter))
            {
                if (mNumParticles + mNumBatchedParticles + nextPS.mNumParticles > MAX_PARTICLES)
                {
                    trace("Over " + MAX_PARTICLES + " particles! Aborting rendering");
                    break;
                }
                vertexes.fixed = false;
                var targetIndex:int = (mNumParticles + mNumBatchedParticles) * 32; // 4 * 8
                var sourceIndex:int = 0;
                var sourceEnd:int = nextPS.mNumParticles * 32; // 4 * 8
                while (sourceIndex < sourceEnd)
                {
                    nextPS.vertexes[int(targetIndex++)] = vertexes[int(sourceIndex++)];
                }
                vertexes.fixed = true;

                mNumBatchedParticles += nextPS.mNumParticles;

                nextPS.mBatched = true;

                //disable filter of batched system temporarily
                nextPS.filter = null;
            }
        }
        return mNumBatchedParticles
    }

    private function renderCustom(support:RenderSupport, mNumBatchedParticles : int, parentAlpha:Number):void
    {
        StarlingParticleBuffers.switchVertexBuffer();

        if (mNumParticles == 0 || StarlingParticleBuffers.buffersCreated == false)
        {
            return;
        }
        // always call this method when you write custom rendering code!
        // it causes all previously batched quads/images to render.
        support.finishQuadBatch();
        support.raiseDrawCount();

        var context:Context3D = Starling.context;
        if (context == null)
        {
            throw new MissingContextError();
        }

        var blendFactors:Array = BlendMode.getBlendFactors(blendMode, true);
        context.setBlendFactors(blendFactors[0], blendFactors[1]);

        const renderAlpha:Vector.<Number> = new <Number>[parentAlpha, parentAlpha, parentAlpha, parentAlpha];
        const renderMatrix:Matrix3D = new Matrix3D();
        MatrixUtil.convertTo3D(support.mvpMatrix, renderMatrix);

        context.setProgram(ParticleProgram.getProgram(mTexture != null, mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, texSmoothing));
        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, renderAlpha, 1);
        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, renderMatrix, true);
        context.setTextureAt(0, mTexture.base);

        StarlingParticleBuffers.vertexBuffer.uploadFromVector(vertexes, 0, Math.min(MAX_PARTICLES * 4, vertexes.length / 8));
        context.setVertexBufferAt(0, StarlingParticleBuffers.vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

        if (mTinted)
        {
            context.setVertexBufferAt(1, StarlingParticleBuffers.vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
        }
        context.setVertexBufferAt(2, StarlingParticleBuffers.vertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

        context.drawTriangles(StarlingParticleBuffers.indexBuffer, 0, (Math.min(MAX_PARTICLES, mNumParticles + mNumBatchedParticles)) * 2);

        context.setVertexBufferAt(2, null);
        context.setVertexBufferAt(1, null);
        context.setVertexBufferAt(0, null);
        context.setTextureAt(0, null);
    }

    public override function set filter(value:FragmentFilter):void
    {
        if (!mBatched)
        {
            mFilter = value;
        }
        super.filter = value;
    }

    override public function getBounds(targetSpace:DisplayObject,resultRect:Rectangle = null):Rectangle
    {
        if (boundsRect == null)
        {
            boundsRect = new Rectangle();
        }
        return boundsRect;
    }

}
}
