package ;

import nme.events.SampleDataEvent;
import nme.utils.ByteArray;

#if cpp
import cpp.Lib;
import cpp.vm.Thread;
#elseif neko
import neko.Lib;
#end

#if android
import nme.JNI;
#end

/**
 * @author Scythian
 */

class DynamicSound 
{
	//public variables
	public static var bufferSize(default, null) : Int;
	
	//private variables
	private static var listener : SampleDataEvent -> Void;
	private static var position : Float = 0;

	private static var t : Thread;
	//private static var gt : Thread;
	
	
	public function new()	{	}
	
	
	public function addEventListener(type:String, thelistener : SampleDataEvent -> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		
		if (type != 'sampleData')
			return;
		
		listener = thelistener;
	}
	
	
	public function play() {
		t = Thread.create(thread_func);
		//gt = Thread.create(generator_func);
	}
	
	public function stop() {
		t.sendMessage("stop");
	}
	
	
	public function thread_func() {
		
		var data = processSampleData();		//prepare part of data beforehand

		var cpp_create 		= Lib.load ("test", "create", 1);
		var cpp_play 		= Lib.load ("test", "play", 0);
		var cpp_feed 		= Lib.load ("test", "feed", 1);
		var cpp_stop 		= Lib.load ("test", "stop", 0);
		var cpp_bufferSize 	= Lib.load ("test", "bufferSize", 0);
		
		trace("Started thread. Buffer length is " + data.length + " samples");
		
		cpp_create(bufferSize << 3);
		cpp_feed(data);
		cpp_play();
		
		while (true)
		{
			var msg = Thread.readMessage(false);		//non-blocking
			if (msg == "stop")
				break;
			
			data = processSampleData();
			cpp_feed(data);
		}

	}
	
	
	public function setBufferSize(samples : Int) {
		bufferSize = samples;
	}
	
	
	public function getBufferSize() : Int
	{
		if (bufferSize != 0)
			return bufferSize;
		
		var cpp_bufferSize 	= Lib.load ("test", "bufferSize", 0);
		
		bufferSize = cpp_bufferSize() >> 3;
		return bufferSize;
	}
	
	
	private static function processSampleData() {
		var e = new SampleDataEvent('sampleData', false, false, position);
		listener(e);
		
		position += 2048;
		
		var float_data = new Array<Float>();
		e.data.position = 0;
		while (e.data.bytesAvailable > 0)
			float_data.push(e.data.readFloat());
			
		return float_data;
	}

	
}