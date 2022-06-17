#!/bin/bash

function divdir
{
    rm /tmp/btft*
    ls -l | grep btft|grep ^d|gawk '{print $9}'>/tmp/alldir

    for line in `cat /tmp/alldir`
    do 
        ls $line |grep src
        if [[ $? == 0 ]];then
        echo $line >>/tmp/btftdirhassrc
            ls $line/src |grep xml
            if [[ $? == 0 ]];then
                    echo $line>>/tmp/btftdir1
            else
                    
                    echo $line>>/tmp/btftdir2
            fi
        else
        echo $line>>/tmp/btftdirnosrc
        fi
    done
}

function createdir
{
# cd /tmp;git clone https://github.com/zhekunzhang/btft_hello.git;cd -   
#    /home/test/workspace/validation/testcases/android_mode/compatibility 
    for line in `cat /tmp/btftdir1`
    do
       cd /home/test/workspace/validation/testcases/android_mode/compatibility/$line;mkdir gradle_src 
       cd /home/test/workspace/validation/testcases/android_mode/compatibility/$line/gradle_src
       cp -r /tmp/btft_hello/gradle_src/* .
       cp -r  ../src/jni .;cp -r ../src/src .;cp ../src/AndroidManifest.xml .;cp ../src/ndk_config .
       sed -i "s/btft_hello/$line/g"  settings.gradle

    done
}


divdir
createdir

