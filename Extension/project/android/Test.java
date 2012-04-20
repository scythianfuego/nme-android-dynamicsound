import android.util.Log;
import java.lang.reflect.Method;

public class Test {
	
	static{
		System.load("/data/data/org.haxenme.extensiontest/libtest.so");
	}
	
	public native void cb();
	
	
	public static String test_cb_call() {
		try {
			Test test = new Test();
			test.cb();
		} catch (Error e){
			return "Error " + e.toString();
		} catch (Exception e){
			return "Exception " + e.toString();
		}
		return "Ok";
	}
	
	public static String getName () {
		
		return "Java";
		
	}
	
	
	public static int twoPlusTwo () {
		
		return 2 + 2;
		
	}
	
	
	
	
}

