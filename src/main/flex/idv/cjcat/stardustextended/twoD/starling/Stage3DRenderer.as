package idv.cjcat.stardustextended.twoD.starling {

import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.events.Event;
import flash.geom.Matrix3D;

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

public class Stage3DRenderer extends DisplayObject
{
    public static const MAX_PARTICLES:int = 16383;
    private static const DEGREES_TO_RADIANS : Number = Math.PI / 180;
    private static const SOURCE_BLEND_FACTOR:String = Context3DBlendFactor.SOURCE_ALPHA;
    private static const DESTINATION_BLEND_FACTOR:String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
    private static const sCosLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
    private static const sSinLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
    private static var numberOfVertexBuffers:int;
    private static var sLUTsCreated:Boolean = false;

    private var mFilter:FragmentFilter;
    private var mTinted : Boolean = true;
    private var mTexture : Texture;
    private var mBatched : Boolean;
    private var vertexData:Vector.<Number>;
    public var mNumParticles:int = 0;
    public var texSmoothing : String;

    public function Stage3DRenderer()
    {
        if (StarlingParticleBuffers.buffersCreated == false)
        {
            init();
        }
        vertexData = new <Number>[];
        Starling.current.context.enableErrorChecking = true;
    }

    /** numberOfBuffers is the amount of vertex buffers used by the particle system for multi buffering. Multi buffering
     *  can avoid stalling of the GPU but will also increases it's memory consumption. */
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

    public function advanceTime(mParticles : Vector.<Particle>, texture : Texture):void
    {
        mTexture = texture;
        mNumParticles = mParticles.length;
        var particle:Particle2D;
        var vertexID:int = 0;

        var red:Number = 1;
        var green:Number = 1;
        var blue:Number = 1;
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

        var textureWidth : uint = 1;
        var textureHeight : uint = 1;

        var textureHalfWidth : uint = mTexture.width / 2;
        var textureHalfHeight : uint = mTexture.height / 2;

        for (var i:int = 0; i < mNumParticles; ++i)
        {
            vertexID = i << 2;
            particle = Particle2D(mParticles[i]);

            particleAlpha = particle.alpha;

            rotation = particle.rotation * DEGREES_TO_RADIANS;
            x = particle.x;
            y = particle.y;

            xOffset = textureHalfWidth * particle.scale; //frameDimensions.particleHalfWidth;
            yOffset = textureHalfHeight * particle.scale; //frameDimensions.particleHalfHeight;
            var textureX : Number = 0;
            var textureY : Number = 0;

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

                vertexData[position] = x - cosX + sinY;  // 0-2: position
                vertexData[++position] = y - sinX - cosY;
                vertexData[++position] = red;// 2-5: Color [0-1]
                vertexData[++position] = green;
                vertexData[++position] = blue;
                vertexData[++position] = particleAlpha;
                vertexData[++position] = textureX; // 6,7: Texture coords [?-1]
                vertexData[++position] = textureY;

                vertexData[++position] = x + cosX + sinY;
                vertexData[++position] = y + sinX - cosY;
                vertexData[++position] = red;
                vertexData[++position] = green;
                vertexData[++position] = blue;
                vertexData[++position] = particleAlpha;
                vertexData[++position] = textureWidth;
                vertexData[++position] = textureY;

                vertexData[++position] = x - cosX - sinY;
                vertexData[++position] = y - sinX + cosY;
                vertexData[++position] = red;
                vertexData[++position] = green;
                vertexData[++position] = blue;
                vertexData[++position] = particleAlpha;
                vertexData[++position] = textureX;
                vertexData[++position] = textureHeight;

                vertexData[++position] = x + cosX - sinY;
                vertexData[++position] = y + sinX + cosY;
                vertexData[++position] = red;
                vertexData[++position] = green;
                vertexData[++position] = blue;
                vertexData[++position] = particleAlpha;
                vertexData[++position] = textureWidth;
                vertexData[++position] = textureHeight;
            }
            else
            {
                vertexData[position] = x - xOffset;
                vertexData[++position] = y - yOffset;
                vertexData[++position] = red;
                vertexData[++position] = green;
                vertexData[++position] = blue;
                vertexData[++position] = particleAlpha;
                vertexData[++position] = textureX;
                vertexData[++position] = textureY;

                vertexData[++position] = x + xOffset;
                vertexData[++position] = y - yOffset;
                vertexData[++position] = red;
                vertexData[++position] = green;
                vertexData[++position] = blue;
                vertexData[++position] = particleAlpha;
                vertexData[++position] = textureWidth;
                vertexData[++position] = textureY;

                vertexData[++position] = x - xOffset;
                vertexData[++position] = y + yOffset;
                vertexData[++position] = red;
                vertexData[++position] = green;
                vertexData[++position] = blue;
                vertexData[++position] = particleAlpha;
                vertexData[++position] = textureX;
                vertexData[++position] = textureHeight;

                vertexData[++position] = x + xOffset;
                vertexData[++position] = y + yOffset;
                vertexData[++position] = red;
                vertexData[++position] = green;
                vertexData[++position] = blue;
                vertexData[++position] = particleAlpha;
                vertexData[++position] = textureWidth;
                vertexData[++position] = textureHeight;
            }
        }
    }

    public function isStateChange(tinted:Boolean, parentAlpha:Number, texture:Texture,
                                  smoothing:String, blendMode:String, blendFactorSource:String,
                                  blendFactorDestination:String, filter:FragmentFilter):Boolean
    {
        if (mNumParticles == 0)
        {
            return false;
        }
        else if (mTexture != null && texture != null)
        {
            return mTexture.base != texture.base || mTexture.repeat != texture.repeat ||
                   texSmoothing != smoothing || mTinted != (tinted || parentAlpha != 1.0) ||
                   this.blendMode != blendMode || SOURCE_BLEND_FACTOR != blendFactorSource ||
                   DESTINATION_BLEND_FACTOR != blendFactorDestination || mFilter != filter;
        }
        return true;
    }

    public override function render(support:RenderSupport, parentAlpha:Number):void
    {
        if (mNumParticles > 0 && !mBatched)
        {
            var mNumBatchedParticles : int = batchNeighbours();
            renderCustom(support, mNumBatchedParticles);
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
            // TODO: randomize particles + determine which texture to use for each particle
            var nextPS:Stage3DRenderer = parent.getChildAt(last) as Stage3DRenderer;
            if (nextPS != null && nextPS.mNumParticles > 0 &&
                !nextPS.isStateChange(mTinted, alpha, mTexture, texSmoothing, blendMode, SOURCE_BLEND_FACTOR, DESTINATION_BLEND_FACTOR, mFilter))
            {
                if (mNumParticles + mNumBatchedParticles + nextPS.mNumParticles > MAX_PARTICLES)
                {
                    trace("Over " + MAX_PARTICLES + " particles! Aborting rendering");
                    break;
                }
                vertexData.fixed = false;
                var targetIndex:int = (mNumParticles + mNumBatchedParticles) * 32; // 4 * 8
                var sourceIndex:int = 0;
                var sourceEnd:int = nextPS.mNumParticles * 32; // 4 * 8
                while (sourceIndex < sourceEnd)
                {
                    nextPS.vertexData[int(targetIndex++)] = vertexData[int(sourceIndex++)];
                }
                vertexData.fixed = true;

                mNumBatchedParticles += nextPS.mNumParticles;

                nextPS.mBatched = true;

                //disable filter of batched system temporarily
                nextPS.filter = null;
            }
        }
        return mNumBatchedParticles
    }

    private function renderCustom(support:RenderSupport, mNumBatchedParticles : int):void
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

        var blendFactors:Array = BlendMode.getBlendFactors(blendMode, false);
        Starling.context.setBlendFactors(blendFactors[0], blendFactors[1]);

        const renderAlpha:Vector.<Number> = new <Number>[1, 1, 1, alpha];
        const renderMatrix:Matrix3D = new Matrix3D();
        MatrixUtil.convertTo3D(support.mvpMatrix, renderMatrix);

        context.setProgram(ParticleProgram.getProgram(mTexture != null, mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, texSmoothing));
        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, renderAlpha, 1);
        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, renderMatrix, true);
        context.setTextureAt(0, mTexture.base);

        StarlingParticleBuffers.vertexBuffer.uploadFromVector(vertexData, 0, Math.min(MAX_PARTICLES * 4, vertexData.length / 8));
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

}
}
