package idv.cjcat.stardustextended.twoD.actions
{
import idv.cjcat.stardustextended.twoD.zones.Zone;

public interface IZoneContainer
{
    function get zones() : Vector.<Zone>;

    function set zones( value : Vector.<Zone> ) : void;
}
}
