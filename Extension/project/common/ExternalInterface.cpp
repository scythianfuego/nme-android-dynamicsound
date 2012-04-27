#ifndef IPHONE
#define IMPLEMENT_API
#endif

#if defined(HX_WINDOWS) || defined(HX_MACOS) || defined(HX_LINUX)
#define NEKO_COMPATIBLE
#endif

#ifdef ANDROID

#include <hx/CFFI.h>
#include <stdio.h>
#include <jni.h>
#include <android/log.h>

extern "C" {

	#ifdef __GNUC__
	  #define JAVA_EXPORT __attribute__ ((visibility("default"))) JNIEXPORT
	#else
	  #define JAVA_EXPORT JNIEXPORT
	#endif

	JavaVM *gJVM=0;

	static jclass AudioTrackProxy = NULL;


	jint JNI_OnLoad(JavaVM *vm, void *reserved)
	{
		gJVM = vm;
		JNIEnv* env = NULL;
		jint result = -1;
	
		if (vm->GetEnv((void**) &env, JNI_VERSION_1_4) != JNI_OK) {
			__android_log_write(ANDROID_LOG_ERROR, "NME DynamicSound", "Native code: failed to initialize JNI");
			return result;
		}
	
		jclass localRefCls = env->FindClass("AudioTrackProxy");
		if (localRefCls == NULL) {
			__android_log_write(ANDROID_LOG_ERROR, "NME DynamicSound", "Native code: failed to find AudioTrackProxy class");
			return result;	 
		}

		AudioTrackProxy = (jclass)env->NewGlobalRef(localRefCls);
		env->DeleteLocalRef(localRefCls);
		if (AudioTrackProxy == NULL) {
			__android_log_write(ANDROID_LOG_ERROR, "NME DynamicSound", "Native code: failed to create a global reference");
			return result;	 
		}
	
		return JNI_VERSION_1_4;
	}

}


jshort* to_arr;


static value jni_call(int what, value param) {
	JNIEnv *env = 0;
	gJVM->AttachCurrentThread(&env, NULL);
	jint result;
	jmethodID mid;

	switch (what)
	{
		case 1:	//create
			{
				mid = env->GetStaticMethodID(AudioTrackProxy, "create", "(I)V");
				env->CallStaticVoidMethod(AudioTrackProxy, mid, val_int(param));
				int size = val_int(param);
				to_arr = new jshort[size];
			}
			break;

		case 2:	//play
			mid = env->GetStaticMethodID(AudioTrackProxy, "play", "()V");
			env->CallStaticVoidMethod(AudioTrackProxy, mid);
			break;

		case 3:	//feed
			{
				mid = env->GetStaticMethodID(AudioTrackProxy, "feed", "([S)V");
				jdouble* from_arr = val_array_double(param);
				int size = val_array_size(param);
				
				//copy double to short
				for(int i=0; i<size; i++)
					to_arr[i] = (short)(0x7fff * from_arr[i]);
				
				jshortArray j_arr = (jshortArray)(env->NewShortArray(size));
				env->SetShortArrayRegion(j_arr, 0, size, to_arr);
				env->CallStaticVoidMethod(AudioTrackProxy, mid, j_arr);
				env->DeleteLocalRef(j_arr);
			}
			break;

		case 4:	//stop
			{
				mid = env->GetStaticMethodID(AudioTrackProxy, "stop", "()V");
				env->CallStaticVoidMethod(AudioTrackProxy, mid);
				delete[] to_arr;
			}
			break;

		case 5: //buffer
			mid = env->GetStaticMethodID(AudioTrackProxy, "bufferSize", "()I");
			result = env->CallStaticIntMethod(AudioTrackProxy, mid);
			return alloc_int(result);
			break;
			
		case 6: //priority
			mid = env->GetStaticMethodID(AudioTrackProxy, "setAudioPriority", "()V");
			result = env->CallStaticIntMethod(AudioTrackProxy, mid);
			break;
			
	}

	return alloc_null();
}

static value create(value b)		{ jni_call(1, b); }				DEFINE_PRIM (create, 1);
static value play()					{ jni_call(2, alloc_null()); }	DEFINE_PRIM (play, 0);
static value feed(value f)			{ jni_call(3, f); }				DEFINE_PRIM (feed, 1);
static value stop()					{ jni_call(4, alloc_null()); }	DEFINE_PRIM (stop, 0);
static value bufferSize()			{ jni_call(5, alloc_null()); }	DEFINE_PRIM (bufferSize, 0);
static value audioPriority()		{ jni_call(6, alloc_null()); }	DEFINE_PRIM (audioPriority, 0);


//important

extern "C" void test_main () {
	// Here you could do some initialization, if needed
}
DEFINE_ENTRY_POINT (test_main);

extern "C" int test_register_prims () { return 0; }

#endif



