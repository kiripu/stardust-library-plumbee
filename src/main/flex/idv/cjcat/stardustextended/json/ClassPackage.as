package idv.cjcat.stardustextended.json
{

/**
 * An <code>JsonBuilder</code> object needs to know the mapping between an XML tag's name and an actual class.
 * This class encapsulates multiple classes for the <code>JsonBuilder.registerClassesFromClassPackage()</code> method
 * to register multiple classes (i.e. build the mapping relations).
 */
public class ClassPackage
{
    protected var classes : Vector.<Class>;

    public function ClassPackage()
    {
        classes = new Vector.<Class>();
        populateClasses();
    }

    /**
     * Returns an array of classes.
     * @return
     */
    public final function getClasses() : Vector.<Class>
    {
        return classes.concat();
    }

    /**
     * [Abstract Method] Populates classes.
     */
    protected function populateClasses() : void
    {

    }
}
}