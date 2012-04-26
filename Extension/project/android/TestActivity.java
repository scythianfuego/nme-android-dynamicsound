/*
package com.oyra.test;

import android.app.Activity;
import android.os.Bundle;

public class TestActivity extends Activity {
    // Called when the activity is first created.
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        float[]buf = new float[Middle.getMinBufferSize()];
        for (int i=0; i<buf.length; i++){
        	buf[i] = (float)((Math.sin(i/Math.PI/2))*0.9);
        }
        Middle.play(buf); 
    }
}
*/