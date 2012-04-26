package ;

import cpp.vm.Mutex;
import haxe.Timer;
import DynamicSoundDataEvent;

#if cpp
import cpp.Lib;
import cpp.vm.Thread;
import cpp.vm.Lock;
import cpp.Sys;
#elseif neko
import neko.Lib;
#end

#if android
import nme.JNI;
#end

/**
 * @author Scythian
 */

private class LockedBuffer
{
	private var m: Mutex;
	private var data: Array<Float>;
	private var data_for_write: Array<Float>;
	private var counter: Int;
	
	public function takeData() {
		m.acquire();
		data = data_for_write;
		data_for_write = null;
		m.release();
		return data;

	}
	
	public function acquire() {
		m.acquire();
	}
	
	public function putData(newdata : Array<Float>) {
		data_for_write = newdata;
		m.release();
	}
	

	public function new()
	{
		m = new Mutex();
		data = null; 
	}

}
 

class DynamicSound 
{
	//public variables
	public static var bufferSize(default, null) : Int;
	
	//private variables
	private static var listener : DynamicSoundDataEvent -> Void;
	private static var position : Float = 0;

	private static var player_thread : Thread;
	private static var generator_thread : Thread;
	
	private static var event : DynamicSoundDataEvent;
	
	//cpp calls
	private static var cpp_create 		= Lib.load ("test", "create", 1);
	private static var cpp_play 		= Lib.load ("test", "play", 0);
	private static var cpp_feed 		= Lib.load ("test", "feed", 1);
	private static var cpp_stop 		= Lib.load ("test", "stop", 0);
	private static var cpp_bufferSize 	= Lib.load ("test", "bufferSize", 0);
	
	public function new()	{}
	
	
	public function listen(thelistener : DynamicSoundDataEvent -> Void):Void {
		listener = thelistener;
		event = new DynamicSoundDataEvent();	
	}
	
	
	public function play() {
		var locker = new LockedBuffer();
		
		player_thread  = Thread.create(thread_func);
		generator_thread = Thread.create(generator_func);

		generator_thread.sendMessage(locker);
		generator_thread.sendMessage(1);
		
		player_thread.sendMessage(locker);
		player_thread.sendMessage(generator_thread);
	}
	
	public function stop() {
		player_thread.sendMessage("stop");
	}
	
	
	public function generator_func()
	{
		var locker : LockedBuffer = Thread.readMessage(true);
		
		while (true) {
			var unlocked = Thread.readMessage(true);
			locker.acquire();
			locker.putData(processSampleData());
		}
	}
	
	
	public function thread_func() {
		
		var locker : LockedBuffer = Thread.readMessage(true);
		var generator : Thread = Thread.readMessage(true);

		var data = null;
		while (data == null)		
			data = locker.takeData();
			
		generator.sendMessage(1);
		
		trace("Started thread. Buffer length is " + data.length + " samples");
		
		cpp_create(bufferSize << 3);	//stereo 32bit
		cpp_feed(data);
		cpp_play();
		
		while (true)
		{
			var msg = Thread.readMessage(false);		//non-blocking
			if (msg == "stop")
				break;
	
			data = locker.takeData();
			generator.sendMessage(1);
			cpp_feed(data);
		}
	}
	
	
	public function setBufferSize(samples : Int) {
		bufferSize = samples;
	}
	
	
	public function getBufferSize() : Int
	{
		if (bufferSize == 0)
			bufferSize = cpp_bufferSize() >> 3;
			
		return bufferSize;
	}
	
	
	private static function processSampleData() {
		event.data = new Array<Float>();	// .splice(0, event.data.length);
		listener(event);
		event.position += bufferSize;
	
		return event.data;
	}

	
}