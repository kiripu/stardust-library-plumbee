package idv.cjcat.stardustextended.twoD {

import idv.cjcat.stardustextended.common.actions.ColorGradient;
import idv.cjcat.stardustextended.common.xml.ClassPackage;
	import idv.cjcat.stardustextended.twoD.actions.Accelerate;
	import idv.cjcat.stardustextended.twoD.actions.AccelerationZone;
	import idv.cjcat.stardustextended.twoD.actions.Collide;
	import idv.cjcat.stardustextended.twoD.actions.Damping;
	import idv.cjcat.stardustextended.twoD.actions.DeathZone;
	import idv.cjcat.stardustextended.twoD.actions.Deflect;
	import idv.cjcat.stardustextended.twoD.actions.Explode;
	import idv.cjcat.stardustextended.twoD.actions.FollowWaypoints;
	import idv.cjcat.stardustextended.twoD.actions.Gravity;
	import idv.cjcat.stardustextended.twoD.actions.Impulse;
	import idv.cjcat.stardustextended.twoD.actions.Move;
	import idv.cjcat.stardustextended.twoD.actions.MutualGravity;
	import idv.cjcat.stardustextended.twoD.actions.NormalDrift;
	import idv.cjcat.stardustextended.twoD.actions.Oriented;
	import idv.cjcat.stardustextended.twoD.actions.RandomDrift;
	import idv.cjcat.stardustextended.twoD.actions.Spawn;
	import idv.cjcat.stardustextended.twoD.actions.SpeedLimit;
	import idv.cjcat.stardustextended.twoD.actions.Spin;
	import idv.cjcat.stardustextended.common.actions.triggers.DeflectorTrigger;
	import idv.cjcat.stardustextended.common.actions.triggers.ZoneTrigger;
	import idv.cjcat.stardustextended.twoD.actions.VelocityField;
	import idv.cjcat.stardustextended.twoD.deflectors.BoundingBox;
	import idv.cjcat.stardustextended.twoD.deflectors.BoundingCircle;
	import idv.cjcat.stardustextended.twoD.deflectors.CircleDeflector;
	import idv.cjcat.stardustextended.twoD.deflectors.LineDeflector;
	import idv.cjcat.stardustextended.twoD.deflectors.WrappingBox;
	import idv.cjcat.stardustextended.twoD.fields.BitmapField;
	import idv.cjcat.stardustextended.twoD.fields.RadialField;
	import idv.cjcat.stardustextended.twoD.fields.UniformField;
	import idv.cjcat.stardustextended.twoD.handlers.PixelHandler;
    import idv.cjcat.stardustextended.twoD.initializers.DisplayObjectClass;
	import idv.cjcat.stardustextended.twoD.initializers.LazyInitializer;
	import idv.cjcat.stardustextended.twoD.initializers.Omega;
	import idv.cjcat.stardustextended.twoD.initializers.Position;
    import idv.cjcat.stardustextended.twoD.initializers.PositionAnimated;
    import idv.cjcat.stardustextended.twoD.initializers.Rotation;
	import idv.cjcat.stardustextended.twoD.initializers.Velocity;
	import idv.cjcat.stardustextended.twoD.zones.BitmapZone;
	import idv.cjcat.stardustextended.twoD.zones.CircleContour;
	import idv.cjcat.stardustextended.twoD.zones.CircleZone;
	import idv.cjcat.stardustextended.twoD.zones.Composite;
	import idv.cjcat.stardustextended.twoD.zones.Line;
	import idv.cjcat.stardustextended.twoD.zones.RectContour;
	import idv.cjcat.stardustextended.twoD.zones.RectZone;
	import idv.cjcat.stardustextended.twoD.zones.Sector;
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
			classes.push(Move);
			classes.push(MutualGravity);
			classes.push(NormalDrift);
			classes.push(Oriented);
			classes.push(Spawn);
			classes.push(SpeedLimit);
			classes.push(Spin);
			classes.push(VelocityField);
			classes.push(AccelerationZone);
			classes.push(ColorGradient);

			//2D action triggers
			classes.push(DeflectorTrigger);
			classes.push(ZoneTrigger);
			
			//2D deflectors
			classes.push(BoundingBox);
			classes.push(BoundingCircle);
			classes.push(CircleDeflector);
			classes.push(LineDeflector);
			classes.push(WrappingBox);
			
			//2D fields
			classes.push(BitmapField);
			classes.push(RadialField);
			classes.push(UniformField);
			
			//2D initializers
			classes.push(DisplayObjectClass);
			classes.push(LazyInitializer);
			classes.push(Omega);
			classes.push(Position);
			classes.push(Rotation);
			classes.push(Velocity);
			classes.push(PositionAnimated);

			//2D particle handlers
			classes.push(PixelHandler);

			//2D zones
			classes.push(BitmapZone);
			classes.push(CircleContour);
			classes.push(CircleZone);
			classes.push(Composite);
			classes.push(Line);
			classes.push(RectContour);
			classes.push(RectZone);
			classes.push(Sector);
			classes.push(SinglePoint);

			classes.push(FollowWaypoints);
		}
	}
}