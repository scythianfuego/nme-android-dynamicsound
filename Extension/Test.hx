package;


#if cpp
import cpp.Lib;
#elseif neko
import neko.Lib;
#end

import nme.JNI;


class Test {
	
	
	public static function getPlatforms ():Array<String> {
		
		var platforms = [ "Haxe" ];
		
		platforms.push (cpp_get_name ());
		
		#if android
			
			if (jni_get_name == null) {
				
				jni_get_name = JNI.createStaticMethod ("Test", "getName", "()Ljava/lang/String;");
				
			}
			
			platforms.push (jni_get_name ());
			
		#end
		
		return platforms;
		
	}
	
	
	public static function printf (message:String):Void {
		
		cpp_call_printf (message);
		
	}
	
	
	public static function twoPlusTwo ():Int {
		
		var answer:Int;
		
		answer = cpp_two_plus_two ();
		
		#if android
			
			if (jni_two_plus_two == null) {
				
				jni_two_plus_two = JNI.createStaticMethod ("Test", "twoPlusTwo", "()I");
				
			}
			
			var secondOpinion = jni_two_plus_two ();
			
			if (answer != secondOpinion) {
				
				throw "Fuzzy math!";
				
			}
			
		#end
		
		return answer;
		
	}
	
	
	#if android
	private static var jni_get_name:Dynamic;
	private static var jni_two_plus_two:Dynamic;
	#end
	
	private static var cpp_call_printf = Lib.load ("test", "test_call_printf", 1);
	private static var cpp_get_name = Lib.load ("test", "test_get_name", 0);
	private static var cpp_two_plus_two = Lib.load ("test", "test_two_plus_two", 0);
	
	
}