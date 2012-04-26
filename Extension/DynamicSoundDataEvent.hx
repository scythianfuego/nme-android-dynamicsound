/**
 * @author Scythian
 * 
 * This file is a part of DynamicSound android NME extension.
 * 
 */

package ;

#if (cpp || neko)

class DynamicSoundDataEvent
{
	public var data : Array<Float>;
	public var position : Float;
	
	public function new()
	{
		this.data = new Array<Float>();
	}
}

#end