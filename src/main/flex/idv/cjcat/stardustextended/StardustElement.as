package idv.cjcat.stardustextended
{

import avmplus.getQualifiedClassName;
import flash.utils.Dictionary;

/**
 * All Stardust elements are subclasses of this class.
 */
public class StardustElement
{

    private static var elementCounter : Dictionary = new Dictionary();

    // needed for JSON serialization
    public var $type : String = getQualifiedClassName(this).split("::")[1];
    public var name : String;

    public function StardustElement()
    {
        var str : String = $type;
        if (elementCounter[str] == undefined) {
            elementCounter[str] = 0;
        }
        else {
            elementCounter[str]++;
        }
        name = str + "_" + elementCounter[str];
    }

    /**
     * This is called when this object's simulation's Json deserialization is complete
     */
    public function OnDeserializationComplete() : void
    {

    }

}
}