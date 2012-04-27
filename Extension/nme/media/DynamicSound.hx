/**
 * @author Scythian
 * 
 * This file is a part of DynamicSound android NME extension.
 * 
 */

package nme.media;

import cpp.vm.Mutex;
import haxe.Timer;
import nme.media.DynamicSoundDataEvent;

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

private class LockedBuffer
{
	private var m: Mutex;
	private var data: Array<Float>;
	private var data_for_write: Array<Float>;
	private var counter: Int;
	private var l : Lock;
	
	
	public function waitForData() {
		l.wait();
		l =  null;
	}
	
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
		if (l != null) l.release();
	}
	

	public function new()
	{
		m = new Mutex();
		l = new Lock();
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
	private static var cpp_create 		= Lib.load ("DynamicSound", "create", 1);
	private static var cpp_play 		= Lib.load ("DynamicSound", "play", 0);
	private static var cpp_feed 		= Lib.load ("DynamicSound", "feed", 1);
	private static var cpp_stop 		= Lib.load ("DynamicSound", "stop", 0);
	private static var cpp_bufferSize 	= Lib.load ("DynamicSound", "bufferSize", 0);
	private static var cpp_audioPriority = Lib.load ("DynamicSound", "audioPriority", 0);
	private static var cpp_detach 		= Lib.load ("DynamicSound", "detach", 0);
	
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
		player_thread.sendMessage(2);
		generator_thread.sendMessage(2);
	}
	
	
	public function generator_func()
	{
		var locker : LockedBuffer = Thread.readMessage(true);
		cpp_audioPriority();
		
		while (true) {
			var msg : Int = Thread.readMessage(true);	//waiting for player
			if (msg == 2)
				break;
				
			locker.acquire();
			locker.putData(processSampleData());
		}
		
		cpp_detach();
	}
	
	
	public function thread_func() {
		
		var locker : LockedBuffer = Thread.readMessage(true);
		var generator : Thread = Thread.readMessage(true);

		locker.waitForData();	

		var data = locker.takeData();
		generator.sendMessage(1);
		
		//trace("Started thread. Buffer length is " + data.length + " samples");
		
		cpp_create(bufferSize << 3);	//stereo 32bit
		cpp_feed(data);
		cpp_play();
		
		while (true)
		{
			var msg : Int = Thread.readMessage(false);		//non-blocking
			if (msg == 2)
				break;
	
			data = locker.takeData();
			generator.sendMessage(1);
			cpp_feed(data);
		}

		cpp_stop();
		cpp_detach();
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