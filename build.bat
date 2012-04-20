set ANT_HOME=D:\android\ant
set ANDROID_SDK=D:\android\sdk
set ANDROID_NDK_ROOT=D:\android\ndk
set JAVA_HOME=c:\Progra~1\Java\jdk1.7.0

cd Extension\project
haxelib run hxcpp Build.xml -Dandroid
cd ..\..\
cd Project
haxelib run nme test soundupdate.nmml android
cd ..