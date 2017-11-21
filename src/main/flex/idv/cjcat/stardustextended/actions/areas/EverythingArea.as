package idv.cjcat.stardustextended.actions.areas
{

/**
 * An area that covers everything
 */
public class EverythingArea extends Area
{

    override public function contains(xc : Number, yc : Number) : Boolean
    {
        return true;
    }
}
}
