package idv.cjcat.stardustextended.zones
{

import idv.cjcat.stardustextended.geom.MotionData2D;

public class ZoneCollection
{
    public var zones : Vector.<Zone> = new Vector.<Zone>();

    [Inline]
    public final function getRandomPointInZones() : MotionData2D
    {
        var md2D : MotionData2D;
        var numZones : uint = zones.length;
        if (numZones > 1)
        {
            var sumArea : Number = 0;
            var areas : Vector.<Number> = new Vector.<Number>();
            for (var i : int = 0; i < numZones; i++)
            {
                sumArea += Zone(zones[i]).getArea();
                areas.push(sumArea);
            }
            var position : Number = Math.random() * sumArea;
            for (i = 0; i < areas.length; i++)
            {
                if (position <= areas[i])
                {
                    md2D = zones[i].getPoint();
                    break;
                }
            }
        }
        else if (numZones == 1)
        {
            md2D = zones[0].getPoint();
        }
        return md2D; // returns null if there are no zones
    }



}
}
