package org.haxenme.extensiontest;

import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.media.DynamicSound;
import nme.media.DynamicSoundDataEvent;
import nme.events.MouseEvent;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;


/**
 * @author Scythian
 * @author Joshua Granick
 * 
 */
class ExtensionTest extends Sprite {
	
	
	private var Label:TextField;
	private var playing: Bool;
	
	public function new () {
		
		super ();
		
		initialize ();
		construct ();
		
	}
	
	//generates test sine wave, frequency unknown atm)

	
	private function construct ():Void {
		
		var s = new DynamicSound();
		var buf_size = 2400;	//samples, function s.getBufferSize() returns minimal possible buffer
		s.setBufferSize(buf_size);
		
		var listener = function(event : DynamicSoundDataEvent) {
			for ( c in 0...buf_size ) { 
				event.data.push(Math.sin((c+event.position) / 5)*0.25);
				event.data.push(Math.sin((c+event.position) / 5)*0.25);
			}
		}
		
		s.listen(listener);

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e) {
			if (!playing)
				s.play();

			playing = true;
		});
		
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, function(e) {
			if (playing)
				s.stop();

			playing = false;
		});
		

		var message = "Tap on screen \nand you will hear a sine sound wave";
		
		Label.defaultTextFormat = new TextFormat ("_sans", 24, 0x222222);
		Label.width = 400;
		Label.x = 10;
		Label.y = 20;
		Label.selectable = false;
		Label.text = message;
		addChild (Label);
		
	}
	
	
	private function initialize ():Void {
		
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		
		Label = new TextField ();
	}
	
	// Entry point
	public static function main () {
		
		trace("[" + Date.now() + "] Application launched"); 
		Lib.current.addChild (new ExtensionTest ());
		
	}
	
	
}