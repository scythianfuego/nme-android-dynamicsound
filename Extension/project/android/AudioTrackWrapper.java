/**
 * @author Oyra
 */

//package ;

import java.io.IOException;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;

public class AudioTrackWrapper implements Runnable{

	private static final String TAG = "AudioTrackWrapper";
	private AudioTrack track = null;
	private short[] buffer = null;

	public static final int FILL_BUFFER = 100;
	public static final int PLAY = 101;
	public static final int STOP = 102;
	
	private static Handler handler;
	
	public AudioTrackWrapper() {
		
		Log.i(TAG, "constructor");
		
		int minSize = getMinBufferSize();
		track = new AudioTrack(AudioManager.STREAM_MUSIC, 44100,
				AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT,
				minSize, AudioTrack.MODE_STREAM);
		buffer = new short[minSize];

	}

	public static int getMinBufferSize(){
		return AudioTrack.getMinBufferSize(44100,
				AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT);
	}
	
	private AudioTrack.OnPlaybackPositionUpdateListener updateListener = new AudioTrack.OnPlaybackPositionUpdateListener()
	{
		public void onPeriodicNotification(AudioTrack player) {
			Log.i("AudioTrackWrapperUL", "onPeriodicNotification");
			Middle.callback();
		}
	
		public void onMarkerReached(AudioTrack recorder) {
			Log.i("AudioTrackWrapperUL", "onMarkerReached");
		}
	};
	
	
	public void stop() {
		Log.i(TAG, "stop");
		try {
			track.stop();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}

	public void play(){
		Log.i(TAG, "play");
		try {
			track.setPlaybackPositionUpdateListener(updateListener);
			track.play();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}

	public void feedData(float[] samples) {
		Log.i(TAG, "feedData");
		fillBuffer(samples);
		track.write(buffer, 0, samples.length);
	}

	private void fillBuffer(float[] samples) {
		Log.i(TAG, "fillBuffer");
		if (buffer.length < samples.length)
			buffer = new short[samples.length];

		for (int i = 0; i < samples.length; i++)
			buffer[i] = (short) (samples[i] * Short.MAX_VALUE);
		;
	}

	@Override
	public void run() {
		// TODO Auto-generated method stub
		Log.i(TAG, "run");
		Looper.prepare();
		handler = new Handler() {
            public void handleMessage(Message msg) {
            	if (msg.what == FILL_BUFFER) {
            		float[] samples = msg.getData().getFloatArray("buffer");
            		feedData(samples);
    			} else if (msg.what == PLAY){
    				play();
    			} else if (msg.what == STOP){
    				stop();
    			}
            }
        };
        Middle.setToHandler(handler);

        Looper.loop();
		
		
		
	}

}
