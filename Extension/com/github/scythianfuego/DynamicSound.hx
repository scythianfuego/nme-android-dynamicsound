/**
 * @author Scythian
 * 
 * This file is a part of DynamicSound android NME extension.
 * 
 */

package com.github.scythianfuego;

#if android

import cpp.vm.Mutex;
import haxe.Timer;
import com.github.scythianfuego.DynamicSoundDataEvent;

import cpp.Lib;
import cpp.vm.Thread;
import cpp.vm.Lock;
import cpp.Sys;

import nme.JNI;


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
	
	private static var is_playing : Bool;
	
	//cpp calls
	private static var cpp_create 		= Lib.load ("DynamicSound", "create", 1);
	private static var cpp_play 		= Lib.load ("DynamicSound", "play", 0);
	private static var cpp_feed 		= Lib.load ("DynamicSound", "feed", 1);
	private static var cpp_pause 		= Lib.load ("DynamicSound", "pause", 0);
	private static var cpp_stop 		= Lib.load ("DynamicSound", "stop", 0);
	private static var cpp_bufferSize 	= Lib.load ("DynamicSound", "bufferSize", 0);
	private static var cpp_audioPriority = Lib.load ("DynamicSound", "audioPriority", 0);
	private static var cpp_detach 		= Lib.load ("DynamicSound", "detach", 0);
	
	public function new()	{
		is_playing = false;
	}
	
	
	public function listen(thelistener : DynamicSoundDataEvent -> Void):Void {
		listener = thelistener;
	}
	
	public function play() {
		
		if (is_playing || listener == null)
			return; 
		
		if (bufferSize == 0)
			getBufferSize();	
			
		event = new DynamicSoundDataEvent();
		//Using the following thread message exchange codes:
		//1 - play or resume playing
		//2 - pause playback
		//3 - need more data
		//4 - full stop
		
		is_playing = true;
		if (player_thread == null)
		{
			var locker = new LockedBuffer();
			
			player_thread = Thread.create(thread_func);
			generator_thread = Thread.create(generator_func);

			generator_thread.sendMessage(locker);
			generator_thread.sendMessage(player_thread);
			
			player_thread.sendMessage(locker);
			player_thread.sendMessage(generator_thread);
		}
		
		generator_thread.sendMessage(1);		//play or resume
	}
	
	public function stop() {
		
		if (!is_playing)
			return;
			
		player_thread.sendMessage(2);
		generator_thread.sendMessage(2);
		is_playing = false;
	}
	
	public function shutdown() {
		if (player_thread != null)
		{
			player_thread.sendMessage(4);
			generator_thread.sendMessage(4);
		}
	}
	
	
	public function generator_func()
	{
		var msg : Int = 0;
		var locker : LockedBuffer = Thread.readMessage(true);
		var player : Thread = Thread.readMessage(true);
		var is_first_chunk = false;
		cpp_audioPriority();
		
		while (true) {	
			msg = Thread.readMessage(true);	//waiting for player
			//trace("generator recv " + msg + " on " + Timer.stamp());
				
			if (msg == 2)		//paused, skipping generation
				continue;
			else if (msg == 4)	//full stop
				break;
			
			locker.acquire();
			locker.putData(processSampleData());
			
			if (msg == 1) 	//the player is waiting fo us in blocking call
				player.sendMessage(1);
		}
		
		cpp_detach();
	}
	
	
	public function thread_func() {
		var msg : Int = 0;
		var locker : LockedBuffer = Thread.readMessage(true);
		var generator : Thread = Thread.readMessage(true);
		cpp_create(bufferSize << 3);	//stereo 32bit
		
		while (true)
		{
			//trace("player idle " + Timer.stamp());
			msg = Thread.readMessage(true);				//blocking call - wait for fist chunk of data
			if (msg == 4)								//fullstop
				break;
			
			//trace("player data arrived" + Timer.stamp());
			var data = locker.takeData();
			generator.sendMessage(3);		//generate more
			cpp_feed(data);					//blocking call
			cpp_play();
			
			while (true)
			{
				msg = Thread.readMessage(false);		//non-blocking
				if (msg == 2)							//paused
					break;
		
				data = locker.takeData();
				generator.sendMessage(3);				//generate more
				cpp_feed(data);							//blocking jni call
			}
			
			cpp_pause();
		}

		cpp_stop();
		cpp_detach();
	}
	
	
	public function setBufferSize(samples : Int) {
		if (player_thread != null)
			return;
		
		bufferSize = samples;
	}
	
	
	public function getBufferSize() : Int
	{
		if (player_thread == null && bufferSize == 0)
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


#end