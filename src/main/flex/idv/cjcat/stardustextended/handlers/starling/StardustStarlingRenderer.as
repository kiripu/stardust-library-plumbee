package idv.cjcat.stardustextended.handlers.starling
{
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DVertexBufferFormat;
import flash.display3D.textures.TextureBase;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.Endian;

import idv.cjcat.stardustextended.particles.Particle;

import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.errors.MissingContextError;
import starling.events.Event;
import starling.filters.FragmentFilter;
import starling.rendering.Painter;
import starling.textures.Texture;

public class StardustStarlingRenderer extends DisplayObject
	{
	    /** The offset of position data (x, y) within a vertex. */
	    private static const POSITION_OFFSET:int = 0;
	    
		/** The offset of color data (r, g, b, a) within a vertex. */
	    private static const COLOR_OFFSET:int = 2;
		
	    /** The offset of texture coordinates (u, v) within a vertex. */
	    private static const TEXCOORD_OFFSET:int = 6;

	    private static const DEGREES_TO_RADIANS:Number = Math.PI / 180;
		
		private static const ANGLE_CONSTANT:Number = 325.94932345220164765467394738691;
		private static const ANGLE_CONSTANT_2:int = 2047;
		
		private static const SINUS_COSINUS_CONSTANT:Number = 0.00306796157577128245943617517898;
		

	    private static const sCosLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
	    private static const sSinLUT:Vector.<Number> = new Vector.<Number>(0x800, true);
	    private static const renderAlpha:Vector.<Number> = new Vector.<Number>(4);

	    private static var initCalled:Boolean = false;

		private static var numBatchedParticles:uint = 0;
		private static var batchedVertexesBa:ByteArray;

		private var boundsRect:Rectangle;
	    private var mFilter:FragmentFilter;
	    private var mTexture:Texture;
	    private var mBatched:Boolean;

		private var vertexesBa:ByteArray;
		
	    private var frames:Vector.<Frame>;
	
	    public var mNumParticles:uint = 0;

	    public var texSmoothing:String;
	    public var premultiplyAlpha:Boolean = true;
	
		private var _id:Number;
	
	    public function StardustStarlingRenderer()
	    {
	        if(initCalled === false)
			{
	            init();
	        }

			vertexesBa = new ByteArray();
			vertexesBa.endian = Endian.LITTLE_ENDIAN;

			if (!batchedVertexesBa)
			{
				batchedVertexesBa = new ByteArray();
				batchedVertexesBa.endian = Endian.LITTLE_ENDIAN;
			}
	    }
	
	    /** 
		 *  numberOfBuffers is the amount of vertex buffers used by the particle system for multi buffering.
	     *  Multi buffering can avoid stalling of the GPU but will also increases it's memory consumption.
	     *  If you want to avoid stalling create the same amount of buffers as your maximum rendered emitters at the
	     *  same time.
	     *  Allocating one buffer with the maximum amount of particles (16383) takes up 2048KB(2MB) GPU memory.
	     *  This call requires that there is a Starling context
	     **/
	    public static function init():void
	    {
	        StarlingParticleBuffers.createBuffers();
	
	        if (!initCalled)
			{
	            for (var i : int = 0; i < 0x800; ++i)
				{
	                sCosLUT[i & 0x7FF] = Math.cos(i * SINUS_COSINUS_CONSTANT);
	                sSinLUT[i & 0x7FF] = Math.sin(i * SINUS_COSINUS_CONSTANT);
	            }
	
	            // handle a lost device context
	            Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
	            initCalled = true;
	        }
	    }
	
	    private static function onContextCreated(event:Event):void
	    {
	        StarlingParticleBuffers.createBuffers();
	    }
	
	    public function setTextures(texture:Texture, _frames:Vector.<Frame>):void
	    {
	        mTexture = texture;
	        frames = _frames;
	    }
		
		private var particle : Particle;
		private var vertexID : int = 0;
		
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		private var particleAlpha:Number;
		
		private var _rotation:Number;
		private var xPos:Number, yPos:Number;
		private var xOffset:Number, yOffset:Number;
		
		private var angle:uint;
		private var cos:Number;
		private var sin:Number;
		private var cosX:Number;
		private var cosY:Number;
		private var sinX:Number;
		private var sinY:Number;
		private var position:uint;
		private var frame:Frame;
		private var bottomRightX:Number;
		private var bottomRightY:Number;
		private var topLeftX:Number;
		private var topLeftY:Number;
	
		private var _i:int;

		[Inline]
	    final public function advanceTime(mParticles : Vector.<Particle>):void
	    {
	        mNumParticles = mParticles.length;

			vertexesBa.position = 0;
			vertexesBa.length = mNumParticles * 32 * 4;

			for(_i = 0; _i < mNumParticles; _i++)
			{
				particle = mParticles[_i];

				// color & alpha
				particleAlpha = particle.alpha;

				if(premultiplyAlpha)
				{
					red = particle.colorR * particleAlpha;
					green = particle.colorG * particleAlpha;
					blue = particle.colorB * particleAlpha;
				}
				else
				{
					red = particle.colorR;
					green = particle.colorG;
					blue = particle.colorB;
				}

				// position & rotation
				_rotation = particle.rotation * DEGREES_TO_RADIANS;
				xPos = particle.x;
				yPos = particle.y;

				// texture
				frame = frames[particle.currentAnimationFrame];
				
				bottomRightX = frame.bottomRightX;
				bottomRightY = frame.bottomRightY;

				topLeftX = frame.topLeftX;
				topLeftY = frame.topLeftY;
				
				xOffset = frame.particleHalfWidth * particle.scale;
				yOffset = frame.particleHalfHeight * particle.scale;
				
				if(_rotation != 0)
				{
					angle = (_rotation * ANGLE_CONSTANT) & ANGLE_CONSTANT_2;
					cos = sCosLUT[angle];
					sin = sSinLUT[angle];
					cosX = cos * xOffset;
					cosY = cos * yOffset;
					sinX = sin * xOffset;
					sinY = sin * yOffset;
	
					vertexesBa.writeFloat(xPos - cosX + sinY);
					vertexesBa.writeFloat(yPos - sinX - cosY);
					
					vertexesBa.writeFloat(red);
					vertexesBa.writeFloat(green);
					vertexesBa.writeFloat(blue);
					vertexesBa.writeFloat(particleAlpha);
					
					
					vertexesBa.writeFloat(topLeftX);
					vertexesBa.writeFloat(topLeftY);
					
					vertexesBa.writeFloat(xPos + cosX + sinY);
					vertexesBa.writeFloat(yPos + sinX - cosY);
					
					vertexesBa.writeFloat(red);
					vertexesBa.writeFloat(green);
					vertexesBa.writeFloat(blue);
					vertexesBa.writeFloat(particleAlpha);
					
					vertexesBa.writeFloat(bottomRightX);
					vertexesBa.writeFloat(topLeftY);
					
					vertexesBa.writeFloat(xPos - cosX - sinY);
					vertexesBa.writeFloat(yPos - sinX + cosY);
					
					vertexesBa.writeFloat(red);
					vertexesBa.writeFloat(green);
					vertexesBa.writeFloat(blue);
					vertexesBa.writeFloat(particleAlpha);
					
					vertexesBa.writeFloat(topLeftX);
					vertexesBa.writeFloat(bottomRightY);
					
					vertexesBa.writeFloat(xPos + cosX - sinY);
					vertexesBa.writeFloat(yPos + sinX + cosY);
					
					vertexesBa.writeFloat(red);
					vertexesBa.writeFloat(green);
					vertexesBa.writeFloat(blue);
					vertexesBa.writeFloat(particleAlpha);
					
					vertexesBa.writeFloat(bottomRightX);
					vertexesBa.writeFloat(bottomRightY);
				}
				else
				{
					
					vertexesBa.writeFloat(xPos - xOffset);
					vertexesBa.writeFloat(yPos - yOffset);
					

					vertexesBa.writeFloat(red);
					vertexesBa.writeFloat(green);
					vertexesBa.writeFloat(blue);
					vertexesBa.writeFloat(particleAlpha);
					
					
					vertexesBa.writeFloat(topLeftX);
					vertexesBa.writeFloat(topLeftY);
					
					vertexesBa.writeFloat(xPos + xOffset);
					vertexesBa.writeFloat(yPos - yOffset);
					
					vertexesBa.writeFloat(red);
					vertexesBa.writeFloat(green);
					vertexesBa.writeFloat(blue);
					vertexesBa.writeFloat(particleAlpha);
					
					vertexesBa.writeFloat(bottomRightX);
					vertexesBa.writeFloat(topLeftY);
					
					vertexesBa.writeFloat(xPos - xOffset);
					vertexesBa.writeFloat(yPos + yOffset);
					
					vertexesBa.writeFloat(red);
					vertexesBa.writeFloat(green);
					vertexesBa.writeFloat(blue);
					vertexesBa.writeFloat(particleAlpha);
					
					vertexesBa.writeFloat(topLeftX);
					vertexesBa.writeFloat(bottomRightY);
					
					vertexesBa.writeFloat(xPos + xOffset);
					vertexesBa.writeFloat(yPos + yOffset);
					
					vertexesBa.writeFloat(red);
					vertexesBa.writeFloat(green);
					vertexesBa.writeFloat(blue);
					vertexesBa.writeFloat(particleAlpha);
					
					vertexesBa.writeFloat(bottomRightX);
					vertexesBa.writeFloat(bottomRightY);
				}
			}
	    }
	
		[Inline]
	    final protected function isStateChange(texture:TextureBase,
	                                     	   smoothing:String,
											   blendMode:String,
											   filter:FragmentFilter,
	                                     	   premultiplyAlpha:Boolean,
											   numParticles:uint):Boolean
	    {
	        if(mNumParticles === 0)
			{
	            return false;
	        }
	        else if(mNumParticles + numParticles > StarlingParticleBuffers.MAX_PARTICLES_PER_BUFFER)
			{
	            return true;
	        }
	        else if(mTexture != null && texture != null)
			{
	            return mTexture.base != texture || texSmoothing != smoothing || this.blendMode != blendMode ||
	                   mFilter != filter || this.premultiplyAlpha != premultiplyAlpha;
	        }

	        return true;
	    }

		private var _parentAlpha:Number;
		
	    public override function render(painter:Painter):void
	    {
	        painter.excludeFromCache(this); // for some reason it doesnt work if inside the if. Starling bug?
			
	        if (mNumParticles > 0 && !mBatched)
			{
				numBatchedParticles = mNumParticles;
				batchedVertexesBa.position = 0;
				batchedVertexesBa.length = vertexesBa.length;
				batchedVertexesBa.writeBytes(vertexesBa, 0, vertexesBa.length);

				batchNeighbours();

				_parentAlpha = parent ? parent.alpha : 1;

	            renderCustom(painter, _parentAlpha);
	        }

	        //reset filter
	        super.filter = mFilter;
	        mBatched = false;
	    }
	
		private var _batchLast:int;
		private var _batchIsStateChange:Boolean;
		private var _batchNextPS:StardustStarlingRenderer;

		[Inline]
	    final protected function batchNeighbours():void
	    { 
			_batchLast = parent.getChildIndex(this);
			_batchIsStateChange = false;

	        while(++_batchLast < parent.numChildren)
			{
				_batchNextPS = parent.getChildAt(_batchLast) as StardustStarlingRenderer;
				
				_batchIsStateChange = _batchNextPS.isStateChange(
					mTexture.base,
					texSmoothing,
					blendMode,
					mFilter,
					premultiplyAlpha,
					numBatchedParticles
				);
				
	            if(_batchNextPS && !_batchIsStateChange)
				{
	                if(_batchNextPS.mNumParticles > 0)
					{
						numBatchedParticles += _batchNextPS.mNumParticles
						batchedVertexesBa.position = batchedVertexesBa.length;
						_batchNextPS.vertexesBa.position = 0;

						batchedVertexesBa.writeBytes(_batchNextPS.vertexesBa, 0, _batchNextPS.vertexesBa.length);
	
						_batchNextPS.mBatched = true;

	                    //disable filter of batched system temporarily
						_batchNextPS.filter = null;
	                }
	            }
	            else
				{
	                break;
	            }
	        }
	    }
	
		private var _renderContext:Context3D;
		private var _renderTrianglesCount:int;

		[Inline]
	    final private function renderCustom(painter:Painter, parentAlpha:Number):void
	    {
	        if(mNumParticles === 0 || StarlingParticleBuffers.buffersCreated === false)
			{
	            return;
	        }

	        StarlingParticleBuffers.switchVertexBuffer();
	
			_renderContext = Starling.context;
			
	        if(_renderContext === null)
			{
	            throw new MissingContextError();
	        }

			painter.finishMeshBatch();
			painter.drawCount += 1;
			painter.prepareToDraw();

	        BlendMode.get(blendMode).activate();

	        renderAlpha[0] = renderAlpha[1] = renderAlpha[2] = premultiplyAlpha ? parentAlpha : 1;
	        renderAlpha[3] = parentAlpha;

			// calls context.setProgram(_program3D);
	        ParticleProgram.getProgram(mTexture.mipMapping, mTexture.format, texSmoothing).activate();

	        _renderContext.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, renderAlpha, 1);
			_renderContext.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 1, painter.state.mvpMatrix3D, true);

			_renderContext.setTextureAt(0, mTexture.base);
	
			StarlingParticleBuffers.vertexBuffer.uploadFromByteArray(
				batchedVertexesBa,
				0,
				0,
				batchedVertexesBa.length / 32
			);

			_renderContext.setVertexBufferAt(0, StarlingParticleBuffers.vertexBuffer, POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			_renderContext.setVertexBufferAt(1, StarlingParticleBuffers.vertexBuffer, COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			_renderContext.setVertexBufferAt(2, StarlingParticleBuffers.vertexBuffer, TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			
			_renderTrianglesCount = batchedVertexesBa.length / 64;

			_renderContext.drawTriangles(
				StarlingParticleBuffers.indexBuffer,
				0,
				_renderTrianglesCount
			);
	
			_renderContext.setVertexBufferAt(0, null);
			_renderContext.setVertexBufferAt(1, null);
			_renderContext.setVertexBufferAt(2, null);
			_renderContext.setTextureAt(0, null);
	    }
	
	    public override function set filter(value : FragmentFilter) : void
	    {
	        if(!mBatched)
			{
	            mFilter = value;
	        }
			
	        super.filter = value;
	    }
	
	    /**
	     * Stardust does not calculate the bounds of the simulation. In the future this would be possible, but
	     * will be a performance heavy operation.
	     */
	    override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle
	    {
	        if(boundsRect == null)
			{
	            boundsRect = new Rectangle();
	        }

	        return boundsRect;
	    }
		
		override public function dispatchEvent(event:Event):void{}
		override public function dispatchEventWith(type:String, bubbles:Boolean=false, data:Object=null):void{}
		override public function addEventListener(type:String, listener:Function):void{}
		override public function removeEventListener(type:String, listener:Function):void{}
	}
}
