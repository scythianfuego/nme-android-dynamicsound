/**
 * @author Oyra
 */

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.media.AudioTrack;
import android.media.AudioFormat;
import android.util.Log;

public class Middle {
	
	private static final String TAG = "Middle";
	private static Handler toHandler;
	private static Thread t;
	
	static{
		System.load("/data/data/org.haxenme.extensiontest/libtest.so");
	}
	
	public native void cb();		//callback to native - data required
	public native void trace(String s);		//trace to haxe
	
	public static void log(String s) {
		Log.i(TAG, s);
		Middle m = new Middle();
		m.trace(s);
	}
	
	public static void initialise(){
		log("initialise");
		
		AudioTrackWrapper a = new AudioTrackWrapper();
		t = new Thread(a);
		t.start();
	}
	
	//API: starts playback
	public static void play() {				// (float[]f){
		log("play");
		if (t == null)
			initialise();
		while (toHandler == null){
			try {
				Thread.sleep(200);
			} catch (InterruptedException e) {}
			
		}
		//Bundle data = new Bundle();
		//data.putFloatArray("buffer", f);
		sendMsg(AudioTrackWrapper.PLAY, toHandler, null);
	}
	
	
	public static void stop(){
		log("stop");
		sendMsg(AudioTrackWrapper.STOP, toHandler, null);
	}
	
	
	public static void close(){
		log("close");
		if (t != null){
			t.interrupt();
		}
	}
	
	
	//API: recieves portion of audiodata
	public static void send(float[]arr){
		log("send");
		if (arr != null && arr.length > 0){
			Bundle data = new Bundle();
			data.putFloatArray("buffer", arr);
			sendMsg(AudioTrackWrapper.FILL_BUFFER, toHandler, data);
		}
	}
	
	
	public static void setToHandler(Handler toHandler) {
		Log.i(TAG, "setToHandler");			//called from external thread! hxcpp unfriendly
		Middle.toHandler = toHandler;
	}

	
	public static void sendMsg(int whatMsg, Handler handler, Bundle bundle) {
		log("sendMsg");
		try {
			if (handler != null) {
				Log.i(TAG, "sending message " + whatMsg);
				Message msg = Message.obtain();
				msg.what = whatMsg;
				if (bundle != null)
					msg.setData(bundle);
				msg.setTarget(handler);
				msg.sendToTarget();
			}
		} catch (Exception e) {
			Log.e(TAG, "error", e);
		}

	}
	
	//returns buffer size for audiodata
	public static int getMinBufferSize(){
			
		//return AudioTrackWrapper.getMinBufferSize();
		log("getMinBufferSize");
		return AudioTrack.getMinBufferSize(44100,
				AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT);
	}
	
	
	//callback from wrapper - playback data required
	public static void callback(){
		Log.i(TAG, "callback");
		try {		
			Middle m = new Middle();
			m.cb();		//call to native-haxecpp
			
			///*
			float[]buf = new float[Middle.getMinBufferSize()];
	        for (int i=0; i<buf.length; i++){
	        	buf[i] = (float)((Math.sin(i/Math.PI/2))*0.9);
	        }
	        Bundle data = new Bundle();
			data.putFloatArray("buffer", buf);
			sendMsg(AudioTrackWrapper.FILL_BUFFER, toHandler, data);
			//*/
	        
		} catch (Exception e) {
		} catch (Error e){
		}
	}
	
	//test for callback, remove later
	public static String test_callback_call()  {
		log("test_callback");
		try {
			Middle m = new Middle();
			m.trace("low ok");
		} catch (Error e){
			return "Error " + e.toString();
		} catch (Exception e){
			return "Exception " + e.toString();
		}
		return "Ok";
	}
}
