package idv.cjcat.stardustextended.twoD.starling {

import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;

import idv.cjcat.stardustextended.common.particles.Particle;

import idv.cjcat.stardustextended.twoD.particles.Particle2D;

import starling.core.RenderSupport;
import starling.core.Starling;

import starling.display.DisplayObject;
import starling.errors.MissingContextError;
import starling.filters.FragmentFilter;
import starling.textures.Texture;
import starling.utils.MatrixUtil;
import starling.utils.VertexData;

public class CustomRenderer extends DisplayObject
{
    /**
     * The maximum number of particles possible. Can be over 16000, but for performance reasons its maximized at a lower value
     */
    public static const MAX_CAPACITY:int = 10000;

    private var mVertexData:VertexData;
    private var mFilter:FragmentFilter;

    private static var sCosLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
    private static var sSinLUT:Vector.<Number> = new Vector.<Number>(0x800, true);

    private var mTinted : Boolean = true;
    private var mTexture : Texture;
    private var mSmoothing : String;
    private var mPremultipliedAlpha:Boolean = false;
    private const mBlendFuncSource:String = Context3DBlendFactor.SOURCE_ALPHA; // source blend factor, was ONE
    private const mBlendFuncDestination:String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;

    private var mBatched : Boolean;

    private static var sBufferSize:uint = 0;
    private static var sIndexBuffer:IndexBuffer3D;
    private static var sVertexBuffers:Vector.<VertexBuffer3D>;
    private static var sVertexBufferIdx:int = -1;
    private static var sNumberOfVertexBuffers:int;
    private static var sIndices:Vector.<uint>;
    private static var sRenderMatrix:Matrix3D = new Matrix3D;
    private static var sLUTsCreated:Boolean = false;
    private static var sInstances:Vector.<CustomRenderer> = new <CustomRenderer>[];
    private static const DEGREES_TO_RADIANS : Number = Math.PI / 180;

    public var mNumParticles:int = 0;

    public function CustomRenderer()
    {
        sInstances.push(this);

        if (!sVertexBuffers || !sVertexBuffers[0])
        {
            init();
        }

        mVertexData = new VertexData(MAX_CAPACITY * 4);
        Starling.current.context.enableErrorChecking = true;
    }

    public static function init(bufferSize:uint = 0, numberOfBuffers:uint = 1):void
    {
        if (!bufferSize && sBufferSize)
        {
            bufferSize = sBufferSize;
        }
        if (bufferSize > MAX_CAPACITY)
        {
            bufferSize = MAX_CAPACITY;
            trace("Warning: bufferSize exceeds the limit and is set to it's maximum value");
        }
        else if (bufferSize <= 0)
        {
            bufferSize = MAX_CAPACITY;
            trace("Warning: bufferSize can't be lower than 1 and is set to it's maximum value");
        }
        sBufferSize = bufferSize;
        sNumberOfVertexBuffers = numberOfBuffers;
        createBuffers(sBufferSize, numberOfBuffers);

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
        Starling.current.stage3D.addEventListener(flash.events.Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true);
    }

    private static function onContextCreated(event:flash.events.Event):void
    {
        createBuffers(sBufferSize, sNumberOfVertexBuffers);
    }

    public function advanceTime(mParticles : Vector.<Particle>, texture : Texture):void
    {
        mTexture = texture;
        mNumParticles = mParticles.length;
        var particle:Particle2D;

        // update vertex data
        var vertexID:int = 0;

        var red:Number = 1;
        var green:Number = 1;
        var blue:Number = 1;
        var particleAlpha:Number;

        var rotation:Number;
        var x:Number, y:Number;
        var xOffset:Number, yOffset:Number;
        const rawData:Vector.<Number> = mVertexData.rawData;

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
            particle = mParticles[i] as Particle2D;

            // TODO: this decreases performance by a LOT
            /*
            red = ( particle.color >> 16 ) & 0xFF / 255;
            green = ( particle.color >> 8 ) & 0xFF / 255;
            blue = particle.color & 0xFF / 255;
            */

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

                rawData[position] = x - cosX + sinY;  // 0-2: position
                rawData[++position] = y - sinX - cosY;
                rawData[++position] = red;// 2-5: Color [0-1]
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = textureX; // 6,7: Texture coords [?-1]
                rawData[++position] = textureY;

                rawData[++position] = x + cosX + sinY;
                rawData[++position] = y + sinX - cosY;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = textureWidth;
                rawData[++position] = textureY;

                rawData[++position] = x - cosX - sinY;
                rawData[++position] = y - sinX + cosY;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = textureX;
                rawData[++position] = textureHeight;

                rawData[++position] = x + cosX - sinY;
                rawData[++position] = y + sinX + cosY;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = textureWidth;
                rawData[++position] = textureHeight;

            }
            else
            {
                rawData[position] = x - xOffset;
                rawData[++position] = y - yOffset;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = textureX;
                rawData[++position] = textureY;

                rawData[++position] = x + xOffset;
                rawData[++position] = y - yOffset;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = textureWidth;
                rawData[++position] = textureY;

                rawData[++position] = x - xOffset;
                rawData[++position] = y + yOffset;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = textureX;
                rawData[++position] = textureHeight;

                rawData[++position] = x + xOffset;
                rawData[++position] = y + yOffset;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = textureWidth;
                rawData[++position] = textureHeight;
            }
        }
    }

    private static function createBuffers(numParticles:uint, sNumberOfVertexBuffers : int):void
    {
        if (sVertexBuffers)
        {
            for (var i:int = 0; i < sVertexBuffers.length; ++i)
            {
                sVertexBuffers[i].dispose();
            }
        }

        if (sIndexBuffer)
        {
            sIndexBuffer.dispose();
        }

        var context:Context3D = Starling.context;
        if (context == null) throw new MissingContextError();
        if (context.driverInfo == "Disposed") return;

        sVertexBuffers = new Vector.<VertexBuffer3D>();
        sVertexBufferIdx = -1;
        if (ApplicationDomain.currentDomain.hasDefinition("flash.display3D.Context3DBufferUsage"))
        {
            for (i = 0; i < sNumberOfVertexBuffers; ++i)
            {
                // Context3DBufferUsage.DYNAMIC_DRAW; hardcoded for backward compatibility
                sVertexBuffers[i] = context.createVertexBuffer.call(context, numParticles * 4, VertexData.ELEMENTS_PER_VERTEX, "dynamicDraw");
            }
        }
        else
        {
            for (i = 0; i < sNumberOfVertexBuffers; ++i)
            {
                sVertexBuffers[i] = context.createVertexBuffer(numParticles * 4, VertexData.ELEMENTS_PER_VERTEX);
            }
        }

        var zeroBytes:ByteArray = new ByteArray();
        zeroBytes.length = numParticles * 16 * VertexData.ELEMENTS_PER_VERTEX;
        for (i = 0; i < sNumberOfVertexBuffers; ++i)
        {
            sVertexBuffers[i].uploadFromByteArray(zeroBytes, 0, 0, numParticles * 4);
        }
        zeroBytes.length = 0;

        if (!sIndices)
        {
            sIndices = new Vector.<uint>();
            var numVertices:int = 0;
            var indexPosition:int = -1;
            for (i = 0; i < MAX_CAPACITY; ++i)
            {
                sIndices[++indexPosition] = numVertices;
                sIndices[++indexPosition] = numVertices + 1;
                sIndices[++indexPosition] = numVertices + 2;

                sIndices[++indexPosition] = numVertices + 1;
                sIndices[++indexPosition] = numVertices + 3;
                sIndices[++indexPosition] = numVertices + 2;
                numVertices += 4;
            }
        }
        sIndexBuffer = context.createIndexBuffer(numParticles * 6);
        sIndexBuffer.uploadFromVector(sIndices, 0, numParticles * 6);
    }

    ///////////////////////////////// QUAD BATCH MODIFICATIONS /////////////////////////////////

    /** Indicates if specific particle system can be batch to another without causing a state change.
     *  A state change occurs if the system uses a different base texture, has a different
     *  'tinted', 'smoothing', 'repeat' or 'blendMode' (blendMode, blendFactorSource,
     *  blendFactorDestination) setting, or if it has a different filter instance.
     *
     *  <p>In Starling it is not recommended to use the same filter instance for multiple
     *  DisplayObjects. Sharing a filter instance between instances of the FFParticleSystem is
     *  AFAIK the only existing exception to this rule IF the systems will get batched.</p>
     */
    public function isStateChange(tinted:Boolean, parentAlpha:Number, texture:Texture,
                                  pma:Boolean, smoothing:String, blendMode:String, blendFactorSource:String,
                                  blendFactorDestination:String, filter:FragmentFilter):Boolean
    {
        if (mNumParticles == 0)
            return false;
        else if (mTexture != null && texture != null)
            return mTexture.base != texture.base || mTexture.repeat != texture.repeat ||
                    mPremultipliedAlpha != pma || mSmoothing != smoothing || mTinted != (tinted || parentAlpha != 1.0)
                    || this.blendMode != blendMode || this.mBlendFuncSource != blendFactorSource ||
                    this.mBlendFuncDestination != blendFactorDestination || this.mFilter != filter;
        else
            return true;
    }

    public override function render(support:RenderSupport, parentAlpha:Number):void
    {
        if (mNumParticles > 0 && !mBatched)
        {
            var mNumBatchedParticles : int = batchNeighbours();
            renderCustom(support, mNumBatchedParticles, alpha * parentAlpha, support.blendMode);
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
            var nextps:CustomRenderer = parent.getChildAt(last) as CustomRenderer;
            if (nextps != null && nextps.mNumParticles > 0 &&
                !nextps.isStateChange(mTinted, alpha, mTexture, mPremultipliedAlpha, mSmoothing, blendMode, mBlendFuncSource, mBlendFuncDestination, mFilter))
            {
                if (mNumParticles + mNumBatchedParticles + nextps.mNumParticles > sBufferSize)
                {
                    break;
                }
                mVertexData.rawData.fixed = false;
                nextps.mVertexData.copyTo(mVertexData, (mNumParticles + mNumBatchedParticles) * 4, 0, nextps.mNumParticles * 4);
                mVertexData.rawData.fixed = true;
                mNumBatchedParticles += nextps.mNumParticles;

                nextps.mBatched = true;

                //disable filter of batched system temporarily
                nextps.filter = null;
            }
        }
        return mNumBatchedParticles
    }

    private function renderCustom(support:RenderSupport, mNumBatchedParticles : int, parentAlpha:Number = 1.0, blendMode:String = null):void
    {
        sVertexBufferIdx = ++sVertexBufferIdx % sNumberOfVertexBuffers;

        if (mNumParticles == 0 || !sVertexBuffers)
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

        context.setBlendFactors(mBlendFuncSource, mBlendFuncDestination);

        var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
        sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = mPremultipliedAlpha ? alpha : 1.0;
        sRenderAlpha[3] = alpha;

        MatrixUtil.convertTo3D(support.mvpMatrix, sRenderMatrix);

        context.setProgram(ParticleProgram.getProgram(mTexture != null, mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format));
        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, sRenderAlpha, 1);
        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, sRenderMatrix, true);
        context.setTextureAt(0, mTexture.base);

        sVertexBuffers[sVertexBufferIdx].uploadFromVector(mVertexData.rawData, 0, Math.min(sBufferSize * 4, mVertexData.rawData.length / 8));
        context.setVertexBufferAt(0, sVertexBuffers[sVertexBufferIdx], VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

        if (mTinted)
        {
            context.setVertexBufferAt(1, sVertexBuffers[sVertexBufferIdx], VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
        }
        context.setVertexBufferAt(2, sVertexBuffers[sVertexBufferIdx], VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

        context.drawTriangles(sIndexBuffer, 0, (Math.min(sBufferSize, mNumParticles + mNumBatchedParticles)) * 2);

        context.setVertexBufferAt(2, null);
        context.setVertexBufferAt(1, null);
        context.setVertexBufferAt(0, null);
        context.setTextureAt(0, null);
    }



}
}
