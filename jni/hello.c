#include <stdio.h>
#include <stdlib.h>
#include <test.h>
//btft hello 执行步骤
//cd btft_hello&&ndk-build clean && sleep 2 && ndk-build -j32 && sleep 2 && ant debug clean && ant debug 
//cd btft_hello/bin&& adb install hello-debug.apk&&cd ../&&./runCase -p com.intel.btft.hello

int btftmain()
{
printf("hello");
return 0;
}
