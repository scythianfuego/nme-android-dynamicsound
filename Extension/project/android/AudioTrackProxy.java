/**
 * @author Oyra
 */

package com.github.scythianfuego; 
 
import java.io.IOException;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Process;
import android.util.Log;

public class AudioTrackProxy {

	private static final String TAG = "NME DynamicSound";
	private static AudioTrack track = null;
	private static short[] buffer = null;

	public static final int FILL_BUFFER = 100;
	public static final int PLAY = 101;
	public static final int STOP = 102;
	
	public static int minSize = 0;
	
	public static void setAudioPriority() {
		Process.setThreadPriority(Process.THREAD_PRIORITY_AUDIO);
		Log.i(TAG, "Priority set to " + Process.getThreadPriority(Process.myTid()));
	}
	
	public static void create(int req_buffer_size) {

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
		try {
			track.stop();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}
	
	public static void flush() {
		try {
			track.flush();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}
	
	public static void release() {
		try {
			track.release();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}
	
	public static void pause() {
		try {
			track.pause();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}
	
	public static void play(){
		try {
			track.play();
		} catch (IllegalStateException e) {
			Log.e(TAG, "error", e);
		}
	}

	public static void feed(short[] samples) {
		track.write(samples, 0, samples.length);
	}


}
