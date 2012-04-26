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
		
	//jni API calls	
	#if android								
	//private static var jni_device_init:Dynamic;
	private static var jni_device_play:Dynamic;
	private static var jni_device_stop:Dynamic;
	private static var jni_device_close:Dynamic;
	private static var jni_buffer_size:Dynamic;
	private static var jni_feed_data:Dynamic;
	
	
	private static var jni_test_cb_call:Dynamic;
	#end
	
	//native api calls 
	private static var cpp_register_callback = Lib.load ("test", "test_register_callback", 1);
	private static var cpp_register_trace = Lib.load ("test", "test_register_trace", 1);
	
	//private variables
	private static var listener : SampleDataEvent -> Void;
	private static var position : Float = 0;
	private static var data : ByteArray;

	private static var t : Thread;
	
	
	public function new()
	{
		cpp_register_trace(trace_callback);
		cpp_register_callback(cpp_callback);
	}
	
	
	public function addEventListener(type:String, thelistener : SampleDataEvent -> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		
		if (type != 'sampleData')
			return;
		
		listener = thelistener;
	}
	
	
	public function play() {
		t = Thread.create(thread_func);
		//t.sendMessage("stop")
		//devicePlay();
	}
	
	
	public function thread_func() {
		
		//prepare part of data beforehand
		var data = processSampleData();
		//var jni_create = JNI.createStaticMethod ("AudioTrackAPI", "create", "()V");
		
		trace("reg1");
		
		var cpp_play = Lib.load ("test", "play", 0);
		trace("loaded");
		cpp_play();
		
		trace("reg2");
		
		/*
		trace("create created");
		var jni_play = JNI.createStaticMethod ("AudioTrackAPI", "play", "()V");
		var jni_feed_data = JNI.createStaticMethod ("AudioTrackAPI", "feedData", "([F)V");
		
		jni_create();
		jni_feed_data(data);
		jni_play();
		
		while (true)
		{
			var msg = Thread.readMessage(false);		//non-blocking
			//if (msg == "stop")
			//	break;
			
			data = processSampleData();
			jni_feed_data(data);
		}
		*/
	}
	
	
	public function stop() {
		deviceStop();
	}
	
	
	public function getBufferSize() : Int
	{
		return 9600;
		
		if (bufferSize != 0)
			return bufferSize;
		
		if (jni_buffer_size == null) {
			jni_buffer_size = JNI.createStaticMethod ("Middle", "getMinBufferSize", "()I");
		}
		
		bufferSize = jni_buffer_size();
		return bufferSize;
	}
	
	
	
	//for debugging purpose only, remove later
	public function forceCallback() {
		#if android
		trace("forcing callback");
		if (jni_test_cb_call == null)
			jni_test_cb_call = JNI.createStaticMethod ("Middle", "test_callback_call", "()Ljava/lang/String;");
			
		var output = jni_test_cb_call();
		trace(output);
		trace("done forcing callback");
		#end
	}
	
	
	private static function cpp_callback() {
		trace("callback");
		//processSampleData();
	}
	
	private static function trace_callback(what : String)
	{
		trace(what);
	}
	
	
	private static function processSampleData() {
		
		data = new ByteArray();
		var e = new SampleDataEvent('sampleData', false, false, 0, data);
		listener(e);
		
		var float_data = new Array<Float>();
		data.position = 0;
		while (data.bytesAvailable > 0)
			float_data.push(data.readFloat());
			
		return float_data;
		//return data to java
		
		//if (jni_feed_data == null) {
		//	jni_feed_data = JNI.createStaticMethod ("Middle", "send", "([F)V");
		//}
		
		//jni_feed_data(float_data);
	}

	
	public static function devicePlay():Void {
			#if android
			
			//if (jni_device_init == null) {
			//	jni_device_init = JNI.createStaticMethod ("Middle", "initialise", "()V");
			//}
			
			if (jni_device_play == null) {
				jni_device_play = JNI.createStaticMethod ("Middle", "play", "()V");
			}
			
			//jni_device_init();
			
			jni_device_play();

			#end
	}
	
	
	public static function deviceStop():Void {
			#if android
			
			if (jni_device_stop == null) {
				jni_device_stop = JNI.createStaticMethod ("Middle", "stop", "()V");
			}
			
			if (jni_device_close == null) {
				jni_device_close = JNI.createStaticMethod ("Middle", "close", "()V");
			}
			
			jni_device_stop();
			jni_device_close();

			#end
	}
	
	
}