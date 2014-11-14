package idv.cjcat.stardustextended.twoD.starling
{

import idv.cjcat.stardustextended.twoD.particles.Particle2D;

import starling.display.Image;
import starling.utils.Color;

public class StarlingParticle extends Particle2D
{
    public var image:Image;

    override public function init():void
    {
        super.init();
        color = Color.WHITE;
    }

    public function update():void
    {
        image.x = x;
        image.y = y;
        image.scaleX = image.scaleY = scale;
        if (image.rotation != rotation)
        {
            image.rotation = rotation;
        }
        if (image.alpha != alpha)
        {
            image.alpha = alpha;
        }
        if (image.color != color)
        {
            image.color = color;
        }
    }
}
}