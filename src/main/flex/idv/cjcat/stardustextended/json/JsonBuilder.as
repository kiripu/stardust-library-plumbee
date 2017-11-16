package idv.cjcat.stardustextended.json {

import avmplus.getQualifiedClassName;

import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import idv.cjcat.stardustextended.StardustElement;
import idv.cjcat.stardustextended.actions.Action;
import idv.cjcat.stardustextended.actions.waypoints.Waypoint;
import idv.cjcat.stardustextended.deflectors.Deflector;
import idv.cjcat.stardustextended.emitters.Emitter;
import idv.cjcat.stardustextended.fields.Field;
import idv.cjcat.stardustextended.initializers.Initializer;
import idv.cjcat.stardustextended.xml.ClassPackage;
import idv.cjcat.stardustextended.zones.Zone;

public class JsonBuilder {

    private var elementClasses : Dictionary;

    private static const ARRAY_ACTION : String = "Array.Action";
    private static const ARRAY_INITIALIZER : String = "Array.Initializer";
    private static const ARRAY_ZONE : String = "Array.Zone";
    private static const ARRAY_FIELD : String = "Array.Field";
    private static const ARRAY_WAYPOINT : String = "Array.Waypoint";
    private static const ARRAY_DEFLECTOR : String = "Array.Deflector";

    private static const TYPE_VAR : String = "$type";
    private static const VALUES_VAR : String = "$values";

    public function JsonBuilder()
    {
        elementClasses = new Dictionary();
    }

    public static function buildJson(emitter : Emitter) : String
    {
        var str : String = JSON.stringify(emitter, replacer, "  ");
        return str;
    }

    private static function replacer(key : *, val : *) : *
    {
        if (key != VALUES_VAR)
        {
            if (val is Vector.<Action>)
            {
                return {$type:ARRAY_ACTION, $values:val};
            }
            else if (val is Vector.<Initializer>)
            {
                return {$type:ARRAY_INITIALIZER, $values:val};
            }
            else if (val is Vector.<Zone>)
            {
                return {$type:ARRAY_ZONE, $values:val};
            }
            else if (val is Vector.<Field>)
            {
                return {$type:ARRAY_FIELD, $values:val};
            }
            else if (val is Vector.<Waypoint>)
            {
                return {$type:ARRAY_WAYPOINT, $values:val};
            }
            else if (val is Vector.<Deflector>)
            {
                return {$type:ARRAY_DEFLECTOR, $values:val};
            }
            else if (val is Array)
            {
                throw new IllegalOperationError("Cannot build JSON from " + val + " for " + key);
            }
        }
        return val;
    }

    public function buildFromJson(jsonStr : String) : Emitter
    {
        var result : Object = JSON.parse(jsonStr);
        var em : Emitter = Emitter(parseSubTree(result));
        return em;
    }

    private function parseSubTree(obj : Object) : Object
    {
        var typeStr : String = obj[TYPE_VAR];
        if (elementClasses[typeStr] != null)
        {
            var cl : Class = elementClasses[typeStr];
            var newInst : StardustElement = new cl();
            for (var key:String in obj)
            {
                var val : * = obj[key];
                if (key == TYPE_VAR || val == null)
                {
                    continue;
                }
                if (val is int || val is uint || val is Number || val is String || val is Boolean)
                {
                    newInst[key] = val;
                }
                else
                {
                    newInst[key] = parseSubTree(val);
                }
            }
            newInst.onXMLInitComplete();
            return newInst;
        }
        else
        { // assume its an array
            var arr : Array = obj[VALUES_VAR];
            var newArr : *;
            var typeVar : String = obj[TYPE_VAR];
            if (typeVar == ARRAY_ACTION)
            {
                newArr = new Vector.<Action>();
            }
            else if (typeVar == ARRAY_INITIALIZER)
            {
                newArr = new Vector.<Initializer>();
            }
            else if (typeVar == ARRAY_FIELD)
            {
                newArr = new Vector.<Field>();
            }
            else if (typeVar == ARRAY_ZONE)
            {
                newArr = new Vector.<Zone>();
            }
            else if (typeVar == ARRAY_WAYPOINT)
            {
                newArr = new Vector.<Waypoint>();
            }
            else if (typeVar == ARRAY_DEFLECTOR)
            {
                newArr = new Vector.<Deflector>();
            }
            else
            {
                throw new IllegalOperationError("Cannot find type of " + obj);
            }
            for each (var elem : Object in arr)
            {
                newArr.push(parseSubTree(elem));
            }
            return newArr;
        }
    }

    public function registerClasses(classes : Vector.<Class>) : void
    {
        for each (var c : Class in classes)
        {
            registerClass(c);
        }
    }

    public function registerClassesFromClassPackage(classPackage : ClassPackage) : void
    {
        registerClasses(classPackage.getClasses());
    }

    public function registerClass(elementClass : Class) : void
    {
        var element : StardustElement = (new elementClass() as StardustElement);
        if (!element)
        {
            throw new IllegalOperationError(elementClass + " is not a subclass of the StardustElement class.");
        }
        const tagName : String = getQualifiedClassName(element).split("::")[1];
        if (elementClasses[tagName] != undefined)
        {
            throw new IllegalOperationError("This element class name is already registered: " + element.getXMLTagName());
        }
        elementClasses[tagName] = elementClass;
    }
}
}
