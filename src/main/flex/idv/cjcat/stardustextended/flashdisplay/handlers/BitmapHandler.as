package idv.cjcat.stardustextended.flashdisplay.handlers
{
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.handlers.ParticleHandler;
import idv.cjcat.stardustextended.math.StardustMath;
import idv.cjcat.stardustextended.particles.Particle;

/**
 * This handler draws display object particles into a bitmap.
 */
public class BitmapHandler extends ParticleHandler
{

    /**
     * The target bitmap to draw display object into.
     */
    public var targetBitmapData : BitmapData;
    /**
     * The blend mode for drawing.
     */
    public var blendMode : String;

    public function BitmapHandler(targetBitmapData : BitmapData = null, blendMode : String = "normal")
    {
        this.targetBitmapData = targetBitmapData;
        this.blendMode = blendMode;
    }

    private var displayObj : DisplayObject;
    private var mat : Matrix = new Matrix();
    private var colorTransform : ColorTransform = new ColorTransform(1, 1, 1);

    override public function stepEnd(emitter : Emitter, particles : Vector.<Particle>, time : Number) : void
    {
        for each (var particle : Particle in particles) {
            displayObj = DisplayObject(particle.target);

            mat.identity();
            mat.scale(particle.scale, particle.scale);
            mat.rotate(particle.rotation * StardustMath.DEGREE_TO_RADIAN);
            mat.translate(particle.x, particle.y);

            colorTransform.alphaMultiplier = particle.alpha;

            targetBitmapData.draw(displayObj, mat, colorTransform, blendMode);
        }
    }

}
}