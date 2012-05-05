nme-android-dynamicsound
========================

**Implementation of generative audio for haxe+NME3+android**

Current version: 0.1.0

This native extension for haxe NME implements generative audio 
for android target by wrapping AudioTrack API.

**Curent limitations and issues**

- only one DynamicSound object at a time
  (don't sure if an issue, AudioTrack API is rather slow)
- listener is called from separate thread, writing a thread safe code could be tricky
- android only ;) 
  flash is rather an inconsistent model for unified generative sound api
- example application doesn't implement fade out to zero volume on note release, so it has clicks
  and sounds unconvincing.
  

**Usage**

Reference the extension in your .nmml:

    <extension name="DynamicSound" path="path/to/nme-android-dynamic/Extension" />

Add imports:

    import com.github.scythianfuego.DynamicSound;
    import com.github.scythianfuego.DynamicSoundDataEvent;

Create a new DynamicSound object:

    var s = new DynamicSound();
    
Request a minimal buffer size (device dependent) or set your own.
The buffer must be set before starting playback.

    var buffer_size = s.getBufferSize();  // minimal possible buffer
    
or

    var buffer_size = 2400;               //should be greater than the minimal one
    s.setBufferSize(buffer_size); 

Buffer size is set in samples, for one out of two channels. Real buffer size on the android device 
will be *buffer_size * 2 (16bit) * 2 (stereo)* bytes.

Add a listener of DynamicSoundDataEvent (it is NOT a subclass of nme.Event) 
The event.data property is an Array<Float>, because current ByteArray implementation in haxe NME
is too slow to use original SampleDataEvent:

    var listener = function(event : DynamicSoundDataEvent) {
      for ( i in 0...buffer_size ) {  
        event.data.push(...);   //left  channel, float -1.0 to 1.0
        event.data.push(...);   //right channel, float -1.0 to 1.0
      }
    }
    s.listen(listener);  

Note that the listener will be called from a separate thread, so you will have to use synchronization
primitives, *mutex for example (have a look at http://haxe.org/api/cpp/vm/thread API) to pass data
between render thread and sound generator thread.
The listener should process a chunk of data faster than playback consumes it, underruns 
(and rather possibly crashes) could be expected otherwise.
	
Control playback:

    s.play();
    s.stop();

The *stop() function makes sound threads wait in thread lock instead of stopping them.
If you want to stop API completely, release threads and resources using

    s.shutdown();	

Note that DynamicSound object is not valid after this action, you'll have to recreate it to use again.
	
**Running the test application**

    build.bat on Windows
    
or

    cd Project
    haxelib run nme test soundupdate.nmml android
	
**Recompiling the extension**

    cd Extension\project
    haxelib run hxcpp Build.xml -Dandroid

**License:**

This  extension and example provided under the main haxe NME project license.