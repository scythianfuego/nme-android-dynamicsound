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
AutoGCRoot *gTraceCallback = 0;
static value test_register_callback(value f);
static value AudioCallback();
static value TraceCallback(const char* s);
static void test_call_printf (value message);

using namespace test;


#include <jni.h>
#include <android/log.h>


#ifdef ANDROID
extern "C" {

#ifdef __GNUC__
  #define JAVA_EXPORT __attribute__ ((visibility("default"))) JNIEXPORT
#else
  #define JAVA_EXPORT JNIEXPORT
#endif

JAVA_EXPORT void JNICALL Java_Middle_cb(JNIEnv *env, jclass myclass) {	
	__android_log_write(ANDROID_LOG_INFO, "Native", "java_middle_cb");
	AudioCallback(); 
}

JAVA_EXPORT void JNICALL Java_Middle_trace(JNIEnv *env, jclass myclass, jstring javaString) {	

	__android_log_write(ANDROID_LOG_INFO, "Native", "java_middle_trace");

	const char *nativeString = env->GetStringUTFChars(javaString, 0);
	TraceCallback(nativeString);
    env->ReleaseStringUTFChars(javaString, nativeString);
}

JavaVM *gJVM=0;

static jclass AudioTrackProxy = NULL;

jint JNI_OnLoad(JavaVM *vm, void *reserved)
{
	gJVM = vm;
	
	JNIEnv* env = NULL;
    jint result = -1;
	
    if (vm->GetEnv((void**) &env, JNI_VERSION_1_4) != JNI_OK) {
        __android_log_write(ANDROID_LOG_INFO, "Native", "jni not loaded");
        return result;
    }
	
	jclass localRefCls = env->FindClass("AudioTrackProxy");
	if (localRefCls == NULL) return NULL; // exception thrown

	AudioTrackProxy = (jclass)env->NewGlobalRef(localRefCls);
	env->DeleteLocalRef(localRefCls);
	if (AudioTrackProxy == NULL) return NULL; // exception thrown
	
	return JNI_VERSION_1_4;
}

}
#endif

static value play()
{

	JNIEnv *env = 0;
	gJVM->AttachCurrentThread(&env, NULL);
	
__android_log_write(ANDROID_LOG_INFO, "Native", "thread attached");

	jmethodID mid = env->GetStaticMethodID(AudioTrackProxy, "play", "()V");
	
	__android_log_print(ANDROID_LOG_INFO, "Native", "env getmethod %d %d", AudioTrackProxy, mid);
	
	if(mid>0)
	{
		env->CallStaticVoidMethod(AudioTrackProxy,mid);
	}
	
	return alloc_null();
}
DEFINE_PRIM (play, 0);

static value test_register_callback (value f) {
	
	__android_log_write(ANDROID_LOG_INFO, "Native", "register_callback");
	 
	
	val_check_function(f,0); 	// checks that f has 0 argument

	 if (!gCallback)
		gCallback = new AutoGCRoot(f);

	return alloc_null();
}
DEFINE_PRIM (test_register_callback, 1);


static value test_register_trace(value f) {
	
	__android_log_write(ANDROID_LOG_INFO, "Native", "register_trace");
	//val_check_function(f,1); 	// checks that f has 1 argument

	if (!gTraceCallback)
		gTraceCallback = new AutoGCRoot(f);

	return alloc_null();
}
DEFINE_PRIM (test_register_trace, 1);


static value TraceCallback(const char* s)
{
	__android_log_write(ANDROID_LOG_INFO, "Native", "TraceCallback");
	if (gTraceCallback)
		val_call1(gTraceCallback->get(), alloc_string(s));
		
	return alloc_null();	
}


static value AudioCallback() {
	__android_log_write(ANDROID_LOG_INFO, "Native", "AudioCallback");
	gc_enter_blocking();
	
	if(gCallback)
		val_call0(gCallback->get());
		
	gc_exit_blocking();
	
	return alloc_null();
}






//unused stuff from example

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