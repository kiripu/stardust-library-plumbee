package idv.cjcat.stardustextended.zones
{
/**
 * Zone with no thickness.
 */
public class Contour extends Zone
{

    protected var _virtualThickness : Number;

    public function Contour()
    {
        _virtualThickness = 1;
    }

    /**
     * Used to calculate "virtual area" for the <code>CompositeZone</code> class,
     * since contours have zero thickness.
     * The larger the virtual thickness, the larger the virtual area.
     */
    public final function get virtualThickness() : Number
    {
        return _virtualThickness;
    }

    public final function set virtualThickness(value : Number) : void
    {
        _virtualThickness = value;
        updateArea();
    }

}
}