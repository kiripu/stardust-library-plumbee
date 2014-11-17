package idv.cjcat.stardustextended.twoD.starling {

import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.Program3D;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import starling.core.RenderSupport;
import starling.core.Starling;

import starling.display.DisplayObject;
import starling.errors.MissingContextError;
import starling.filters.FragmentFilter;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.MatrixUtil;
import starling.utils.VertexData;

public class CustomRenderer extends DisplayObject
{
    private var mVertexData:VertexData;

    private static var sCosLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
    private static var sSinLUT:Vector.<Number> = new Vector.<Number>(0x800, true);

    private static function initLUTs():void
    {
        for (var i:int = 0; i < 0x800; ++i)
        {
            sCosLUT[i & 0x7FF] = Math.cos(i * 0.00306796157577128245943617517898); // 0.003067 = 2PI/2048
            sSinLUT[i & 0x7FF] = Math.sin(i * 0.00306796157577128245943617517898);
        }
    }

    public function advanceTime(passedTime:Number):void
    {
        // update vertex data
        var vertexID:int = 0;

        var red:Number;
        var green:Number;
        var blue:Number;
        var particleAlpha:Number;

        var rotation:Number;
        var x:Number, y:Number;
        var xOffset:Number, yOffset:Number;
        var rawData:Vector.<Number> = mVertexData.rawData;
        var frameDimensions:Frame;

        var angle:uint;
        var cos:Number;
        var sin:Number;
        var cosX:Number;
        var cosY:Number;
        var sinX:Number;
        var sinY:Number;
        var position:uint;

        for (var i:int = 0; i < mNumParticles; ++i)
        {
            vertexID = i << 2;
            particle = mParticles[i];
            frameDimensions = mFrameLUT[particle.frameIdx];

            red = particle.colorRed;
            green = particle.colorGreen;
            blue = particle.colorBlue;

            particleAlpha = particle.colorAlpha * particle.fadeInFactor * particle.fadeOutFactor * mSystemAlpha;

            rotation = particle.rotation;
            x = particle.x;
            y = particle.y;

            xOffset = frameDimensions.particleHalfWidth * particle.scale * particle.spawnFactor;
            yOffset = frameDimensions.particleHalfHeight * particle.scale * particle.spawnFactor;

            if (rotation)
            {
                angle = (rotation * 325.94932345220164765467394738691) & 2047;
                cos = sCosLUT[angle];
                sin = sSinLUT[angle];
                cosX = cos * xOffset;
                cosY = cos * yOffset;
                sinX = sin * xOffset;
                sinY = sin * yOffset;

                position = vertexID << 3; // * 8
                rawData[position] = x - cosX + sinY;
                rawData[++position] = y - sinX - cosY;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = frameDimensions.textureX;
                rawData[++position] = frameDimensions.textureY;

                rawData[++position] = x + cosX + sinY;
                rawData[++position] = y + sinX - cosY;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = frameDimensions.textureWidth;
                rawData[++position] = frameDimensions.textureY;

                rawData[++position] = x - cosX - sinY;
                rawData[++position] = y - sinX + cosY;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = frameDimensions.textureX;
                rawData[++position] = frameDimensions.textureHeight;

                rawData[++position] = x + cosX - sinY;
                rawData[++position] = y + sinX + cosY;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = frameDimensions.textureWidth;
                rawData[++position] = frameDimensions.textureHeight;

            }
            else
            {
                position = vertexID << 3; // * 8
                rawData[position] = x - xOffset;
                rawData[++position] = y - yOffset;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = frameDimensions.textureX;
                rawData[++position] = frameDimensions.textureY;

                rawData[++position] = x + xOffset;
                rawData[++position] = y - yOffset;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = frameDimensions.textureWidth;
                rawData[++position] = frameDimensions.textureY;

                rawData[++position] = x - xOffset;
                rawData[++position] = y + yOffset;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = frameDimensions.textureX;
                rawData[++position] = frameDimensions.textureHeight;

                rawData[++position] = x + xOffset;
                rawData[++position] = y + yOffset;
                rawData[++position] = red;
                rawData[++position] = green;
                rawData[++position] = blue;
                rawData[++position] = particleAlpha;
                rawData[++position] = frameDimensions.textureWidth;
                rawData[++position] = frameDimensions.textureHeight;
            }
        }
    }

    private static var sProgramNameCache:Dictionary = new Dictionary();

    private function getProgram(tinted:Boolean):Program3D
    {
        var target:Starling = Starling.current;
        var programName:String;

        if (mTexture)
            programName = getImageProgramName(mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, mSmoothing);

        var program:Program3D = target.getProgram(programName);

        if (!program)
        {
            // this is the input data we'll pass to the shaders:
            //
            // va0 -> position
            // va1 -> color
            // va2 -> texCoords
            // vc0 -> alpha
            // vc1 -> mvpMatrix
            // fs0 -> texture
            var vertexShader:String;
            var fragmentShader:String;

            if (!mTexture) // Quad-Shaders
            {
                vertexShader = "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
                        "mul v0, va1, vc0 \n"; // multiply alpha (vc0) with color (va1)

                fragmentShader = "mov oc, v0       \n"; // output color
            }
            else // Image-Shaders
            {
                vertexShader = tinted ? "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
                        "mul v0, va1, vc0 \n" + // multiply alpha (vc0) with color (va1)
                        "mov v1, va2      \n" // pass texture coordinates to fragment program
                        : "m44 op, va0, vc1 \n" + // 4x4 matrix transform to output clipspace
                        "mov v1, va2      \n"; // pass texture coordinates to fragment program

                fragmentShader = tinted ? "tex ft1,  v1, fs0 <???> \n" + // sample texture 0
                        "mul  oc, ft1,  v0       \n" // multiply color with texel color
                        : "tex  oc,  v1, fs0 <???> \n"; // sample texture 0

                fragmentShader = fragmentShader.replace("<???>", RenderSupport.getTextureLookupFlags(mTexture.format, mTexture.mipMapping, mTexture.repeat, smoothing));
            }
            program = target.registerProgramFromSource(programName, vertexShader, fragmentShader);
        }
        return program;
    }

    private static function getImageProgramName(tinted:Boolean, mipMap:Boolean = true, repeat:Boolean = false, format:String = "bgra", smoothing:String = "bilinear"):String
    {
        var bitField:uint = 0;

        if (tinted)
            bitField |= 1;
        if (mipMap)
            bitField |= 1 << 1;
        if (repeat)
            bitField |= 1 << 2;

        if (smoothing == TextureSmoothing.NONE)
            bitField |= 1 << 3;
        else if (smoothing == TextureSmoothing.TRILINEAR)
            bitField |= 1 << 4;

        if (format == Context3DTextureFormat.COMPRESSED)
            bitField |= 1 << 5;
        else if (format == "compressedAlpha")
            bitField |= 1 << 6;

        var name:String = sProgramNameCache[bitField];

        if (name == null)
        {
            name = "QB_i." + bitField.toString(16);
            sProgramNameCache[bitField] = name;
        }
        return name;
    }

    ///////////////////////////////// QUAD BATCH EXCERPT END /////////////////////////////////

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

    private static var sHelperRect:Rectangle = new Rectangle();

    public override function render(support:RenderSupport, parentAlpha:Number):void
    {
        mNumBatchedParticles = 0;
        getBounds(stage, batchBounds);

        if (mNumParticles)
        {
            if (mBatching)
            {
                if (!mBatched)
                {
                    var first:int = parent.getChildIndex(this);
                    var last:int = first;
                    var numChildren:int = parent.numChildren;

                    while (++last < numChildren)
                    {
                        var next:DisplayObject = parent.getChildAt(last);
                        if (next is FFParticleSystem)
                        {
                            var nextps:FFParticleSystem = FFParticleSystem(next);

                            if (nextps.mParticles && !nextps.isStateChange(mTinted, alpha, mTexture,
                                mPremultipliedAlpha, mSmoothing, blendMode, mBlendFuncSource, mBlendFuncDestination, mFilter))
                            {

                                var newcapacity:int = numParticles + mNumBatchedParticles + nextps.numParticles;
                                if (newcapacity > sBufferSize)
                                    break;

                                mVertexData.rawData.fixed = false;
                                nextps.mVertexData.copyTo(this.mVertexData, (numParticles + mNumBatchedParticles) * 4,
                                                          0, nextps.numParticles * 4);
                                mVertexData.rawData.fixed = true;
                                mNumBatchedParticles += nextps.numParticles;

                                nextps.mBatched = true;

                                //disable filter of batched system temporarily
                                nextps.filter = null;

                                nextps.getBounds(stage, sHelperRect);
                                if (batchBounds.intersects(sHelperRect))
                                    batchBounds = batchBounds.union(sHelperRect);
                            }
                            else
                            {
                                break;
                            }
                        }
                        else
                        {
                            break;
                        }
                    }
                    renderCustom(support, alpha * parentAlpha, support.blendMode);
                }
            }
            else
            {
                renderCustom(support, alpha * parentAlpha, support.blendMode);
            }
        }
        //reset filter
        super.filter = mFilter;
        mBatched = false;
    }

    /** @private */
    private var batchBounds:Rectangle = new Rectangle();

    private function renderCustom(support:RenderSupport, parentAlpha:Number = 1.0, blendMode:String = null):void
    {
        sVertexBufferIdx = ++sVertexBufferIdx % sNumberOfVertexBuffers;

        if (mNumParticles == 0 || !sVertexBuffers)
            return;

        // always call this method when you write custom rendering code!
        // it causes all previously batched quads/images to render.
        support.finishQuadBatch();

        support.raiseDrawCount();

        //alpha *= this.alpha;

        var program:String = getImageProgramName(mTinted, mTexture.mipMapping, mTexture.repeat, mTexture.format, mSmoothing);

        var context:Context3D = Starling.context;

        sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = mPremultipliedAlpha ? alpha : 1.0;
        sRenderAlpha[3] = alpha;

        if (context == null)
            throw new MissingContextError();

        context.setBlendFactors(mBlendFuncSource, mBlendFuncDestination);

        MatrixUtil.convertTo3D(support.mvpMatrix, sRenderMatrix);

        context.setProgram(getProgram(mTinted));
        context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, sRenderAlpha, 1);
        context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, sRenderMatrix, true);
        context.setTextureAt(0, mTexture.base);

        sVertexBuffers[sVertexBufferIdx].uploadFromVector(mVertexData.rawData, 0, Math.min(sBufferSize * 4, mVertexData.rawData.length / 8));

        context.setVertexBufferAt(0, sVertexBuffers[sVertexBufferIdx], VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
        if (mTinted) {
            context.setVertexBufferAt(1, sVertexBuffers[sVertexBufferIdx], VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
        }
        context.setVertexBufferAt(2, sVertexBuffers[sVertexBufferIdx], VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

        if (batchBounds)
            support.pushClipRect(batchBounds);
        context.drawTriangles(sIndexBuffer, 0, (Math.min(sBufferSize, mNumParticles + mNumBatchedParticles)) * 2);
        if (batchBounds)
            support.popClipRect();

        context.setVertexBufferAt(2, null);
        context.setVertexBufferAt(1, null);
        context.setVertexBufferAt(0, null);
        context.setTextureAt(0, null);
    }



}
}
