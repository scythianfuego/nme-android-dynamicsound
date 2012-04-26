/**
 * @author Oyra
 */

import java.io.IOException;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;

public class AudioTrackProxy {

	private static final String TAG = "AudioTrackAPI";
	private static AudioTrack track = null;
	private static short[] buffer = null;

	public static final int FILL_BUFFER = 100;
	public static final int PLAY = 101;
	public static final int STOP = 102;
	
	//private static Handler handler;
	
	public static int minSize = 0;
	
	public static void create(int req_buffer_size) {
		
		Log.i(TAG, "constructor");
		
		minSize = req_buffer_size;
		
		track = new AudioTrack(AudioManager.STREAM_MUSIC, 44100,
				AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT,
				bufferSize(), AudioTrack.MODE_STREAM);
				
		buffer = new short[bufferSize()];

	}

	public static int bufferSize(){
		if (minSize == 0)
			minSize = AudioTrack.getMinBufferSize(44100,
				AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT);
				
		return minSize;
	}
	
	public static void stop() {
		Log.i(TAG, "stop");
		try {
			track.stop();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}
	
	public static void play(){
		Log.i(TAG, "play");
		try {
					//track.setPositionNotificationPeriod(160);
					//track.setPlaybackPositionUpdateListener(updateListener);
			//do not forget to write some data before
			track.play();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}

	public static void feed(short[] samples) {
		Log.i(TAG, "feed" + samples.length);
		track.write(samples, 0, samples.length);
	}

	
	/*
	private static void fillBuffer(float[] samples) {
		Log.i(TAG, "fillBuffer");
		if (buffer.length < samples.length)
			buffer = new short[samples.length];

		for (int i = 0; i < samples.length; i++)
			buffer[i] = (short) (samples[i] * Short.MAX_VALUE);
	}
	*/

}
