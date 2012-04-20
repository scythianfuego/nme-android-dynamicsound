package ;

import nme.events.SampleDataEvent;
import nme.utils.ByteArray;

#if cpp
import cpp.Lib;
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
	private static var jni_device_play:Dynamic;
	private static var jni_device_stop:Dynamic;
	private static var jni_device_close:Dynamic;
	private static var jni_buffer_size:Dynamic;
	private static var jni_feed_data:Dynamic;
	
	private static var jni_test_cb_call:Dynamic;
	#end
	
	//native api calls 
	private static var cpp_register_callback = Lib.load ("test", "test_register_callback", 1);

	//private variables
	private static var listener : SampleDataEvent -> Void;
	private static var position : Float = 0;
	private static var data : ByteArray;

	
	
	public function new()
	{
		
	}
	
	
	public function addEventListener(type:String, thelistener : SampleDataEvent -> Void, useCapture:Bool = false, priority:Int = 0, useWeakReference:Bool = false):Void {
		
		if (type != 'sampleData')
			return;
		
		listener = thelistener;
	}
	
	
	public function play() {
		devicePlay();
		cpp_register_callback(cpp_callback);
	}
	
	public function stop() {
		deviceStop();
	}
	
	
	public function getBufferSize() : Int
	{
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
		
		var jni_call = JNI.createStaticMethod ("Middle", "test_callback_call", "()Ljava/lang/String;");
		var output = jni_call();
		trace(output);
		
		#end
	}
	
	
	private static function cpp_callback() {
		trace("callback");
		processSampleData();
	}
	
	
	private static function processSampleData() {
		
		data = new ByteArray();
		var e = new SampleDataEvent('sampleData', false, false, 0, data);
		listener(e);
		
		var float_data = new Array<Float>();
		data.position = 0;
		while (data.bytesAvailable > 0)
			float_data.push(data.readFloat());
			
		//return data to java
		
		if (jni_feed_data == null) {
			jni_feed_data = JNI.createStaticMethod ("Middle", "send", "([F)V");
		}
		
		jni_feed_data(float_data);
	}

	
	public static function devicePlay():Void {
			#if android
			
			if (jni_device_play == null) {
				jni_device_play = JNI.createStaticMethod ("Middle", "play", "()V");
			}
			
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