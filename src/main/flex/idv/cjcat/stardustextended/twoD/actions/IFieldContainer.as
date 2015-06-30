package idv.cjcat.stardustextended.twoD.actions
{
import idv.cjcat.stardustextended.twoD.fields.Field;

public interface IFieldContainer
{
    function get fields() : Vector.<Field>;

    function set fields( value : Vector.<Field> ) : void;
}
}
