#ifndef IPHONE
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif


#include <hx/CFFI.h>
#include "Utils.h"
#include <stdio.h>

AutoGCRoot *gCallback = 0;
static value test_register_callback(value f);
static value AudioCallback();
static void test_call_printf (value message);

using namespace test;

#ifdef ANDROID
#include <jni.h>

extern "C" {

#ifdef __GNUC__
  #define JAVA_EXPORT __attribute__ ((visibility("default"))) JNIEXPORT
#else
  #define JAVA_EXPORT JNIEXPORT
#endif

JAVA_EXPORT void JNICALL Java_Test_cb(JNIEnv *env, jclass myclass) {	AudioCallback(); }

}
#endif

static value test_register_callback (value f) {
	
	val_check_function(f,0); 	// checks that f has 1 argument

	 if (!gCallback)
		gCallback = new AutoGCRoot(f);

	return alloc_null();
}
DEFINE_PRIM (test_register_callback, 1);

static value AudioCallback() {
	if(gCallback)
		val_call0(gCallback->get());
	
	return alloc_null();
}


static void test_call_printf (value message) {
	
	printf (val_string (message));
	
}
DEFINE_PRIM (test_call_printf, 1);


static value test_get_name () {
	
	return alloc_string (GetName ());
	
}
DEFINE_PRIM (test_get_name, 0);


static value test_two_plus_two () {
	
	return alloc_int (TwoPlusTwo ());
	
}
DEFINE_PRIM (test_two_plus_two, 0);



extern "C" void test_main () {
	
	// Here you could do some initialization, if needed
	
}
DEFINE_ENTRY_POINT (test_main);


extern "C" int test_register_prims () { return 0; }