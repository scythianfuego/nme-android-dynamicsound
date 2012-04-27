nme-android-dynamicsound
========================

**Implementation of generative audio for haxe+NME3+android**

This native extension for haxe NME implements generative audio 
for android target by wrapping AudioTrack API.

**Curent limitations and issues**

- now unusable (I mean it)
- clicks and underruns a lot (should be the ways to repair)
- crashes on thread recreating (bug)
- only one DynamicSound object at a time
  (and this could be an insuperable hindrance, AudioTrack API is rather slow)
- android only ;) 
  because we really should work out the unified generative sound api, 
  and I suppose flash is not a best model

**Usage**

Reference the extension in your .nmml:

    <extension name="DynamicSound" path="path/to/nme-android-dynamic/Extension" />

Add imports:

    import nme.media.DynamicSound;
    import nme.media.DynamicSoundDataEvent;

Create a new DynamicSound object:

    var s = new DynamicSound();
    
Request a minimal buffer size (device dependent) or set your own.
The buffer must be set before starting playback.

    var buffer_size = s.getBufferSize();  // minimal possible buffer
    
or

    var buffer_size = 2400;               //should be greater than the minimal one
    s.setBufferSize(buffer_size); 

Buffer size is set in samples, both channel. Real buffer size on the android device 
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

Control playback:

    s.play();
    s.stop();


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