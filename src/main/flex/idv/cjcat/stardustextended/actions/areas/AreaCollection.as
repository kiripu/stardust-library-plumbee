package idv.cjcat.stardustextended.actions.areas
{

public class AreaCollection
{
    public var areas : Vector.<Area> = new Vector.<Area>();

    public final function contains(xc : Number, yc : Number) : Boolean
    {
        for each (var area : Area in areas)
        {
            if (area.contains(xc, yc))
            {
                return true;
            }
        }
        return false;
    }
}
}
