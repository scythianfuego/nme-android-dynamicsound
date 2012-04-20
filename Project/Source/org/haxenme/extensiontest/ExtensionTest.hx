package org.haxenme.extensiontest;


import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.SampleDataEvent;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;


/**
 * @author Joshua Granick
 */
class ExtensionTest extends Sprite {
	
	
	private var Label:TextField;
	
	
	public function new () {
		
		super ();
		
		initialize ();
		construct ();
		
	}
	
	public static function listener(e : SampleDataEvent) {
		
	}
	
	private function construct ():Void {
		
		var s = new DynamicSound();
		s.addEventListener(SampleDataEvent.SAMPLE_DATA, listener);
		s.play();
		s.forceCallback();
		
		var message = "Math: 2 + 2 = " + Test.twoPlusTwo ();
		message += "\nPlatforms: ";
		
		var platforms = Test.getPlatforms ();
		
		for (i in 0...platforms.length) {
			
			if (i == platforms.length - 1) {
				
				message += " and ";
				
			} else if (i > 0) {
				
				message += ", ";
				
			}
			
			message += platforms[i];
			
		}
		
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