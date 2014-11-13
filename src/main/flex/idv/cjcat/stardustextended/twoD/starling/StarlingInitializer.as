package idv.cjcat.stardustextended.twoD.starling {


import idv.cjcat.stardustextended.common.particles.Particle;
import idv.cjcat.stardustextended.twoD.initializers.Initializer2D;

import starling.display.Image;
import starling.textures.Texture;

public class StarlingInitializer extends Initializer2D {

    private var _image:Image;

    public function set texture(texture:Texture) : void {
        _image = new Image(texture);
    }

    override public function initialize(particle:Particle):void {
        var starlingParticle:StarlingParticle = particle as StarlingParticle;
        starlingParticle.image = _image;
        starlingParticle.image.pivotX = starlingParticle.image.width * 0.5;
        starlingParticle.image.pivotY = starlingParticle.image.height * 0.5;
    }

    //XML
    //------------------------------------------------------------------------------------------------

    override public function getXMLTagName():String {
        return "StarlingInitializer";
    }

    //------------------------------------------------------------------------------------------------
    //end of XML
}
}
