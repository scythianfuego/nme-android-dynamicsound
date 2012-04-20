package ;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;


public class Middle {

	private static final String TAG = "Middle";
	private Handler toHandler;
	private Thread t;
	
	public Middle(){
		AudioTrackWrapper a = new AudioTrackWrapper(this);
		t = new Thread(a);
		t.start();
	}
	public void play(){
		sendMsg(AudioTrackWrapper.PLAY, toHandler, null);
	}
	public void stop(){
		sendMsg(AudioTrackWrapper.STOP, toHandler, null);
	}
	public void close(){
		if (t != null){
			t.interrupt();
		}
	}
	
	
	public void setToHandler(Handler toHandler) {
		this.toHandler = toHandler;
	}
	public void send(float[]arr){
		if (arr != null && arr.length > 0){
			Bundle data = new Bundle();
			data.putFloatArray("buffer", arr);
			sendMsg(AudioTrackWrapper.PLAY, toHandler, null);
		}
	}
	
	public void sendMsg(int whatMsg, Handler handler, Bundle bundle) {
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
	
	
	public int getMinBufferSize(){
		return AudioTrackWrapper.getMinBufferSize();
	}
	public void callback(){
		//you call will be here
	}
}
