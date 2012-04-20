/**
 * @author Oyra
 */

//package ;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

public class Middle {
	
	private static final String TAG = "Middle";
	private static Handler toHandler;
	private static Thread t;
	
	static{
		System.load("/data/data/org.haxenme.extensiontest/libtest.so");
	}
	
	public native void cb();		//callback to native - data required
	
	private static void initialise(){
		AudioTrackWrapper a = new AudioTrackWrapper();
		t = new Thread(a);
		t.start();
	}
	
	//API: starts playback
	public static void play(){
		if (t == null)
			initialise();
			
		sendMsg(AudioTrackWrapper.PLAY, toHandler, null);
	}
	
	
	public static void stop(){
		sendMsg(AudioTrackWrapper.STOP, toHandler, null);
	}
	
	
	public static void close(){
		if (t != null){
			t.interrupt();
		}
	}
	
	
	//API: recieves portion of audiodata
	public static void send(float[]arr){
		if (arr != null && arr.length > 0){
			Bundle data = new Bundle();
			data.putFloatArray("buffer", arr);
			sendMsg(AudioTrackWrapper.PLAY, toHandler, null);
		}
	}
	
	
	public static void setToHandler(Handler toHandler) {
		Middle.toHandler = toHandler;
	}

	
	public static void sendMsg(int whatMsg, Handler handler, Bundle bundle) {
		try {
			if (handler != null) {
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
		return AudioTrackWrapper.getMinBufferSize();
	}
	
	
	//callback from wrapper - playback data required
	public static void callback(){
		try {		
			Middle m = new Middle();
			m.cb();		//call to native-haxecpp
		} catch (Exception e) {
		} catch (Error e){
		}
	}
	
	//test for callback, remove later
	public static String test_callback_call() {
		try {
			Middle m = new Middle();
			m.cb();
		} catch (Error e){
			return "Error " + e.toString();
		} catch (Exception e){
			return "Exception " + e.toString();
		}
		return "Ok";
	}
}
