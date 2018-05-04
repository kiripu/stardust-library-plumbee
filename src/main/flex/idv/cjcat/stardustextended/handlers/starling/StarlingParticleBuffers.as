package idv.cjcat.stardustextended.handlers.starling
{
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import starling.core.Starling;
	import starling.errors.MissingContextError;
	
	public class StarlingParticleBuffers
	{
		
		public static var indexBuffer:IndexBuffer3D;
		
		protected static var vertexBuffers:Vector.<VertexBuffer3D>;
		
		private static var indices:Vector.<uint>;
		private static var indicesBa:ByteArray;
		
		public static const MAX_PARTICLES_PER_BUFFER:int = 4096;//16383;
		
		private static const VERTEX_BUFFER_COUNT:int = 24;
		
		
		protected static var _vertexBufferIdx:int = -1;

		protected static const ELEMENTS_PER_VERTEX:int = 8;
		
		/** Creates buffers for the simulation.
		 * 
		 * numberOfBuffers is the amount of vertex buffers used by the particle system for multi buffering. Multi buffering
		 * can avoid stalling of the GPU but will also increases it's memory consumption.
		 * 
		 * */
		public static function createBuffers():void
		{
			_vertexBufferIdx = -1;
			
			if(vertexBuffers)
			{
				for(var i : int = 0; i < vertexBuffers.length; ++i)
				{
					vertexBuffers[i].dispose();
				}
			}
			
			if (indexBuffer)
			{
				indexBuffer.dispose();
			}
			
			var context:Context3D = Starling.context;
			
			if(context === null) throw new MissingContextError();
			if(context.driverInfo == "Disposed") return;
			
			vertexBuffers = new Vector.<VertexBuffer3D>();
			
			if(ApplicationDomain.currentDomain.hasDefinition("flash.display3D.Context3DBufferUsage"))
			{
				for(i = 0; i < VERTEX_BUFFER_COUNT; ++i)
				{
					// Context3DBufferUsage.DYNAMIC_DRAW; hardcoded for FP 11.x compatibility
					vertexBuffers[i] = context.createVertexBuffer.call(
						context,
						MAX_PARTICLES_PER_BUFFER * 4,
						ELEMENTS_PER_VERTEX,
						"dynamicDraw"
					);
				}
			}
			else
			{
				for(i = 0; i < VERTEX_BUFFER_COUNT; ++i)
				{
					vertexBuffers[i] = context.createVertexBuffer(MAX_PARTICLES_PER_BUFFER * 4, ELEMENTS_PER_VERTEX);
				}
			}
			
			var zeroBytes:ByteArray = new ByteArray();
				zeroBytes.length = MAX_PARTICLES_PER_BUFFER * 16 * ELEMENTS_PER_VERTEX;
			
			for (i = 0; i < VERTEX_BUFFER_COUNT; ++i)
			{
				vertexBuffers[i].uploadFromByteArray(zeroBytes, 0, 0, MAX_PARTICLES_PER_BUFFER * 4);
			}
			
			zeroBytes.length = 0;
			
			if(!indices)
			{
				indicesBa = new ByteArray();
				indicesBa.endian = Endian.LITTLE_ENDIAN;

				var numVertices:int = 0;
				
				for (i = 0; i < MAX_PARTICLES_PER_BUFFER; ++i)
				{
					indicesBa.writeShort(numVertices);
					indicesBa.writeShort(numVertices + 1);
					indicesBa.writeShort(numVertices + 2);
					
					indicesBa.writeShort(numVertices + 1);
					indicesBa.writeShort(numVertices + 3);
					indicesBa.writeShort(numVertices + 2);
					
					numVertices += 4;
				}
			}
			
			indexBuffer = context.createIndexBuffer(MAX_PARTICLES_PER_BUFFER * 6);
			indexBuffer.uploadFromByteArray(indicesBa, 0, 0, MAX_PARTICLES_PER_BUFFER * 6); 
		}
		
		/** 
		 * 
		 * Call this function to switch to the next Vertex buffer before calling uploadFromVector() or uploadFromByteArray 
		 * 
		 * to implement multi buffering. Has only effect if numberOfVertexBuffers > 1
		 * 
		 * */
		[Inline]
		public static function switchVertexBuffer():void
		{
			_vertexBufferIdx = ++_vertexBufferIdx % VERTEX_BUFFER_COUNT;
		}
		
		[Inline]
		public static function get vertexBuffer():VertexBuffer3D
		{
			return vertexBuffers[_vertexBufferIdx];
		}
		
		[Inline]
		public static function get vertexBufferIdx():uint
		{
			return _vertexBufferIdx;
		}
		
		[Inline]
		public static function get buffersCreated():Boolean
		{
			// this has to look like this otherwise ASC 2.0 generates some garbage code
			if(vertexBuffers && vertexBuffers.length > 0)
			{
				return true;
			}
			
			return false;
		}
	}
}
