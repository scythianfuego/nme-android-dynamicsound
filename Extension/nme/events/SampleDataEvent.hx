/**
 * @author Scythian
 * 
 * This is NOT the <SampleDataEvent.hx> file from haXe NME library
 * as at this moment the original NME implementation does not exist.
 * This file is a part of DynamicSound android NME extension, the future library file contents may vary.
 * The only purpose of messing with namespaces is to simplify the future integration.
 * 
 */

package nme.events;
import nme.utils.ByteArray;

#if (cpp || neko)

class SampleDataEvent extends Event
{
	
	public var data : ByteArray;
	public var position : Float;
	public static var SAMPLE_DATA : String = "sampleData";

	
	public function new(type : String, bubbles : Bool = false, cancelable : Bool = false, theposition : Float = 0, ?thedata : flash.utils.ByteArray)
	{
		super(type, bubbles, cancelable);
		this.position = theposition;
		if (this.data != null)
		{
			this.data = thedata;
		}
		else
		{
			this.data = new ByteArray();
			//data.setLength(8192);
		}
	}
	
	
	public override function clone ():Event
	{
		return new SampleDataEvent (type, bubbles, cancelable, position, data);
	}
	
	
	public override function toString ():String
	{
		return "[SampleDataEvent type=" + type + " bubbles=" + bubbles + " cancelable=" + cancelable + " position=" + position + "]";
	}
	
}


#else
typedef TextEvent = flash.events.SampleDataEvent;
#end