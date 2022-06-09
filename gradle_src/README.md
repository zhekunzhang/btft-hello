https://blog.csdn.net/cjhxydream/article/details/90632168

0.gradle 环境下载
config-gradle-env.sh

1.修改manifest 包名
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.intel.btft.hello" android:versionName="r38325" android:versionCode="1">
  <instrumentation android:name="android.test.InstrumentationTestRunner" android:label="sample tests" android:targetPackage="com.intel.btft.hello">

2.修改生成apk名test@qemu05:~/bin/btft-hello$ vim settings.gradle

3.test@qemu05: gradle build

4.adb -s emulator-5556 install ~/bin/btft-hello/build/outputs/apk/gradle-hello-debug.apk

5.adb -s emulator-5556 shell -n am instrument -w -e class com.intel.btft.hello.hello#testbtftmain com.intel.btft.hello/android.test.InstrumentationTestRunner


