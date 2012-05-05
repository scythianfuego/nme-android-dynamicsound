/**
 * @author Scythian
 * @author Joshua Granick
 * 
 */

package com.github.scythianfuego;

import com.github.scythianfuego.DynamicSound;
import com.github.scythianfuego.DynamicSoundDataEvent;
import haxe.Timer;

import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.MouseEvent;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;


class DynamicSoundTest extends Sprite {

	private var playing: Bool;
	private var release: Bool;
	private var mute: Bool;
	
	public function new () {
		super ();
		construct ();
	}

	//== maps a range to another one ==
	private function map(x : Float, in_min : Float, in_max : Float, out_min : Float, out_max : Float) : Float
	{
		return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
	}
	
	
	private function construct ():Void {
		
		//== initializing ==
		var sound = new DynamicSound();
		var bufferSize = sound.getBufferSize(); 	//size in samples
		
		//== the buffer can be set directly: ==
		//var buf_size = 2400;
		//sound.setBufferSize(buf_size);

		
		//== sine wave generators ==
		var listeners = [];
		for (i in 0...12)
		{
			//== tone calculation ==
			var sampleRateMultiplier = 2.0 * Math.PI / 44100;		
			var noteFrequency = Math.pow(2, (3 + i) / 12) * 440;	//A4 + 3 halftones = C5
			var sineMultiplier = sampleRateMultiplier * noteFrequency;
			var maxAmplitude = 0.25;
			
			listeners[i] = function(event : DynamicSoundDataEvent) {
				for ( c in 0...bufferSize ) { 
					
					//== amplitude calculation ==
					var amplitude = maxAmplitude;	//fair ADSR will require thread sync
					var attack = 300;				//samples
					var decay = attack + 150;		//samples + attack length

					if (c <= attack && event.position == 0)
						amplitude = map(c, 0, attack, 0, maxAmplitude + 0.1); 	//attack
					else if (c > attack && c <= decay && event.position == 0)
						amplitude = map(c, attack, decay, maxAmplitude + 0.1, maxAmplitude); 	//decay
						
					//== event data writing ==
					event.data.push(Math.sin((c+event.position) * sineMultiplier) * amplitude);
					event.data.push(Math.sin((c+event.position) * sineMultiplier) * amplitude);
				}
			}
		}
		
		
		//== piano key event handlers ==
		var mouseDown = function(note, sharp = false) {
			release = false;
			mute = false;
			var noteToTone = [0, 2, 4, 5, 7, 9, 11];
			return function(e) {
				var tone = noteToTone[note];
				if (sharp) 
					tone++;
					
				sound.listen(listeners[tone]);
				if (!playing) 
				{
					sound.play();
					playing = true;
				}
			};
		}
		
		var mouseUp = function(e) {
			if (playing)
			{				
				sound.stop();
				playing = false;
			}
		};

		
		//== piano key drawing ==
		var rainbowKey = function(index, x, y, w, h) {
			var colors = [0xff0000, 0xff8000, 0xffff00, 0x008000, 0x0000ff, 0x4B0082, 0x9400D3];
			var s = new Sprite();
			s.graphics.beginFill(colors[index]);
			s.graphics.drawRect(x, y, w, h);
			s.graphics.endFill();
			s.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown(index));
			s.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addChild(s);
		}
		
		var blackKey = function(index, x, y, w, h) {
			var s = new Sprite();
			s.graphics.beginFill(0x0);
			s.graphics.drawRoundRect(x, y, w, h, 40);
			s.graphics.endFill();
			s.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown(index, true));
			s.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addChild(s);
		}
		
		//== adding to stage ==
		var w = Lib.current.stage.stageWidth / 2;
		var h = Lib.current.stage.stageHeight / 7;
		
		for (i in 0...7)
			rainbowKey(i, 0, i * h, w * 2, h);
				
		for (i in 0...6)
			if (i != 2)
				blackKey(i, w, (i + 0.6) * h, w+100, h * 0.8);
		

		//== info message ==
		var message = "Tap the screen \nand you should hear \na sine sound wave";
		
		var Label = new TextField ();
		Label.defaultTextFormat = new TextFormat ("_sans", 24, 0x222222);
		Label.width = 400;
		Label.x = 10;
		Label.y = 20;
		Label.selectable = false;
		Label.text = message;
		Label.mouseEnabled = false;		//do not catch mouse events
		addChild (Label);
		
	}
	
	
	//== entry point ==
	public static function main () {
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.addChild (new DynamicSoundTest());
	}
	
	
}