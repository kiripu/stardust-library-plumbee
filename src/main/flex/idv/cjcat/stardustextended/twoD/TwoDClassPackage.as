﻿package idv.cjcat.stardustextended.twoD {
	import idv.cjcat.stardustextended.common.xml.ClassPackage;
	import idv.cjcat.stardustextended.twoD.actions.Accelerate;
import idv.cjcat.stardustextended.twoD.actions.AnimateSpriteSheet;
import idv.cjcat.stardustextended.twoD.actions.Collide;
	import idv.cjcat.stardustextended.twoD.actions.Damping;
	import idv.cjcat.stardustextended.twoD.actions.DeathZone;
	import idv.cjcat.stardustextended.twoD.actions.Deflect;
	import idv.cjcat.stardustextended.twoD.actions.Explode;
	import idv.cjcat.stardustextended.twoD.actions.FollowWaypoints;
	import idv.cjcat.stardustextended.twoD.actions.Gravity;
	import idv.cjcat.stardustextended.twoD.actions.Impulse;
	import idv.cjcat.stardustextended.twoD.actions.LazyAction;
	import idv.cjcat.stardustextended.twoD.actions.Move;
	import idv.cjcat.stardustextended.twoD.actions.MutualGravity;
	import idv.cjcat.stardustextended.twoD.actions.NormalDrift;
	import idv.cjcat.stardustextended.twoD.actions.Oriented;
	import idv.cjcat.stardustextended.twoD.actions.RandomDrift;
	import idv.cjcat.stardustextended.twoD.actions.ReorderDisplayObject;
	import idv.cjcat.stardustextended.twoD.actions.Snapshot;
	import idv.cjcat.stardustextended.twoD.actions.SnapshotRestore;
	import idv.cjcat.stardustextended.twoD.actions.Spawn;
	import idv.cjcat.stardustextended.twoD.actions.SpeedLimit;
	import idv.cjcat.stardustextended.twoD.actions.Spin;
	import idv.cjcat.stardustextended.twoD.actions.StardustSpriteUpdate;
	import idv.cjcat.stardustextended.twoD.actions.triggers.DeflectorTrigger;
	import idv.cjcat.stardustextended.twoD.actions.triggers.ZoneTrigger;
	import idv.cjcat.stardustextended.twoD.actions.VelocityField;
	import idv.cjcat.stardustextended.twoD.deflectors.BoundingBox;
	import idv.cjcat.stardustextended.twoD.deflectors.BoundingCircle;
	import idv.cjcat.stardustextended.twoD.deflectors.CircleDeflector;
	import idv.cjcat.stardustextended.twoD.deflectors.LineDeflector;
	import idv.cjcat.stardustextended.twoD.deflectors.WrappingBox;
	import idv.cjcat.stardustextended.twoD.emitters.Emitter2D;
	import idv.cjcat.stardustextended.twoD.fields.BitmapField;
	import idv.cjcat.stardustextended.twoD.fields.RadialField;
	import idv.cjcat.stardustextended.twoD.fields.UniformField;
	import idv.cjcat.stardustextended.twoD.handlers.BitmapHandler;
	import idv.cjcat.stardustextended.twoD.handlers.DisplayObjectHandler;
	import idv.cjcat.stardustextended.twoD.handlers.PixelHandler;
	import idv.cjcat.stardustextended.twoD.handlers.SingularBitmapHandler;
import idv.cjcat.stardustextended.twoD.initializers.BitmapParticleInit;
import idv.cjcat.stardustextended.twoD.initializers.DisplayObjectClass;
	import idv.cjcat.stardustextended.twoD.initializers.DisplayObjectParent;
	import idv.cjcat.stardustextended.twoD.initializers.LazyInitializer;
	import idv.cjcat.stardustextended.twoD.initializers.Omega;
	import idv.cjcat.stardustextended.twoD.initializers.PooledDisplayObjectClass;
	import idv.cjcat.stardustextended.twoD.initializers.Position;
import idv.cjcat.stardustextended.twoD.initializers.PositionAnimated;
import idv.cjcat.stardustextended.twoD.initializers.Rotation;
	import idv.cjcat.stardustextended.twoD.initializers.StardustSpriteInit;
	import idv.cjcat.stardustextended.twoD.initializers.Velocity;
	import idv.cjcat.stardustextended.twoD.zones.BitmapZone;
	import idv.cjcat.stardustextended.twoD.zones.CircleContour;
	import idv.cjcat.stardustextended.twoD.zones.CircleZone;
	import idv.cjcat.stardustextended.twoD.zones.CompositeZone;
	import idv.cjcat.stardustextended.twoD.zones.LazySectorZone;
	import idv.cjcat.stardustextended.twoD.zones.Line;
	import idv.cjcat.stardustextended.twoD.zones.RectContour;
	import idv.cjcat.stardustextended.twoD.zones.RectZone;
	import idv.cjcat.stardustextended.twoD.zones.SectorZone;
	import idv.cjcat.stardustextended.twoD.zones.SinglePoint;
	
	/**
	 * Packs together classes for 2D.
	 */
	public class TwoDClassPackage extends ClassPackage {
		
		private static var _instance:TwoDClassPackage;
		
		public static function getInstance():TwoDClassPackage {
			if (!_instance) _instance = new TwoDClassPackage();
			return _instance;
		}
		
		public function TwoDClassPackage() {
			
		}
		
		
		override protected final function populateClasses():void {
			//2D actions
			classes.push(RandomDrift);
			classes.push(Accelerate);
			classes.push(Collide);
			classes.push(Damping);
			classes.push(DeathZone);
			classes.push(Deflect);
			classes.push(Explode);
			classes.push(Gravity);
			classes.push(Impulse);
			classes.push(LazyAction);
			classes.push(Move);
			classes.push(MutualGravity);
			classes.push(NormalDrift);
			classes.push(Oriented);
			classes.push(ReorderDisplayObject);
			classes.push(Snapshot);
			classes.push(SnapshotRestore);
			classes.push(Spawn);
			classes.push(SpeedLimit);
			classes.push(Spin);
			classes.push(StardustSpriteUpdate);
			classes.push(VelocityField);
			classes.push(AnimateSpriteSheet);

			//2D action triggers
			classes.push(DeflectorTrigger);
			classes.push(ZoneTrigger);
			
			//2D deflectors
			classes.push(BoundingBox);
			classes.push(BoundingCircle);
			classes.push(CircleDeflector);
			classes.push(LineDeflector);
			classes.push(WrappingBox);
			
			//2D emitters
			classes.push(Emitter2D);
			
			//2D fields
			classes.push(BitmapField);
			classes.push(RadialField);
			classes.push(UniformField);
			
			//2D initializers
			classes.push(DisplayObjectClass);
			classes.push(DisplayObjectParent);
			classes.push(LazyInitializer);
			classes.push(Omega);
			classes.push(PooledDisplayObjectClass);
			classes.push(Position);
			classes.push(Rotation);
			classes.push(StardustSpriteInit);
			classes.push(Velocity);
			classes.push(PositionAnimated);
			classes.push(BitmapParticleInit);

			//2D particle handlers
			classes.push(BitmapHandler);
			classes.push(DisplayObjectHandler);
			classes.push(SingularBitmapHandler);
			classes.push(PixelHandler);
			
			//2D zones
			classes.push(BitmapZone);
			classes.push(CircleContour);
			classes.push(CircleZone);
			classes.push(CompositeZone);
			classes.push(LazySectorZone);
			classes.push(Line);
			classes.push(RectContour);
			classes.push(RectZone);
			classes.push(SectorZone);
			classes.push(SinglePoint);

			classes.push(FollowWaypoints);
		}
	}
}