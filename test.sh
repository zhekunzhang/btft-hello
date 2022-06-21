#ll!/bin/bash
#set -x 
if [[ $# -lt 1 ]]
then
    clear
    echo "下载hello project 示例  并配置环境"
    echo "  ./test.sh hello.c"
    echo "  ./test.sh [projectname].c"
    echo ""
    echo ""
    echo "generate apk"
    echo "  ./test.sh -n [btft_hello]  -a [ arm32/arm64/x86/x64 ] "
    echo ""
    echo ""
    echo "run one subcase"
    echo "  ./test.sh -n  btft_aeabitest -a arm32  -r AeabiMemset4Test"
    echo ""
    echo ""
    echo "run all case"
    echo "  ./test.sh -n  btft_hello -a arm32  -r all"
    echo ""
    echo "替换ndk    source  ./test.sh -n  btft_hello -a arm32  -r all"

fi

#Application.mk.aarch64 存在abi不一致


count=0
curpath=$PWD
config_gradle()
{
    cd /home/test/bin
    cat ~/.bashrc|grep gradle-2.2> /dev/null
    if [ $? != 0 ];then
        echo "export PATH=/home/test/bin/gradle-2.2/bin:\$PATH">>~/.bashrc
    fi
    
    if [ -d  gradle-2.2 ];then
        echo "gradle exist"
    else
        wget  https://services.gradle.org/distributions/gradle-2.2-all.zip
        unzip gradle-2.2-all.zip
    fi
    source ~/.bashrc
}

switch_abi()
{
        if [ "$project_name" == "" ];then
          exit 1
        fi
        if [ "$1" == "arm32" ]; then
            abi="arm32"
        elif [ "$1" == "arm64" ]; then
            abi="aarch64"
        elif [ "$1" == "x86" ]; then
            abi="x86"
        elif  [ "$1" == "x86_64" ]; then
            abi="x86_64"
        elif [ "$1" == "link" ];then
            path1="/gradle_src/jni/"
            cd $project_name$path1
            if [[ $? != 0 ]];then
                  echo "please check project name"
                     exit 2
            fi
            ln -sf "Application.mk."$abi   Application.mk
        fi
        cd "$curpath"
}


sourcesrc()
{
#ready for the bashrc of differnt version 
ndkversion=`cat ndk_config|grep :|head -n 1|awk -F 'r'  '{print$2}'`
if [[ $ndkversion =~ 10 ]];then
source   ~/.bashrc10
elif [[ $ndkversion =~ 14 ]];then
source   ~/.bashrc14
elif [[ $ndkversion =~ 20 ]];then
source   ~/.bashrc20
elif [[ $ndkversion =~ 21 ]];then
source   ~/.bashrc21
elif [[ "$ndkversion" =~ 22 ]];then
source   ~/.bashrc22
fi
echo $NDK_VERSION
echo "This project use ndk $ndkversion"
}

build_apk_type()
{
        switch_abi link
        cd $project_name/gradle_src
        sourcesrc
        rm -rf build&&rm -rf libs&&rm -rf obj
        echo "ready build ..."
        gradle build   > /dev/null
        cd "build/outputs/apk"
        cp *debug.apk $curpath
        cd "$curpath";cd $project_name;rm -rf build&&rm -rf libs&&rm -rf obj
        cd "$curpath"
}

run_btft()
{
    adb -s emulator-5554 shell -n am instrument -w -e class $package_name.$2\#$1 $package_name/android.test.InstrumentationTestRunner> /dev/null
    if [[ $? == 0  ]]
    then 
    echo "$1 run pass"
    else
    echo "$1 run fail"
    fi

}

run_btft_case()
{
        cd $curpath
        apkname=`ls "$apk_name"*.apk`
        if [[ $? != 0 ]];then
                echo "Please generate apk first"
                exit 2
        fi
        echo $apkname
        cd $curpath
        adb -s emulator-5554 install -r  $apkname

        if [[ "$1" == all  ]]
        then
#            if [[ -f $apk_name/gradle_src/jni/test.cpp  ]];then
#                cat  $apk_name/gradle_src/jni/test.cpp |grep BTFT> /tmp/btft
#                for line in `cat /tmp/btft`
#                do
#                        casename=echo $line|gawk -F\, '{print $2}'|gawk -F\) '{print $1}'
#                        run_btft $casename
#                 done    
#            else
                 rm /tmp/tmpcase
                 cat `ls $apk_name/test/arm32/*xml|head -n 1`|grep TestCase >>/tmp/tmpcase      
                  #处理
                 for line in `cat /tmp/tmpcase`
                  do
                  if [[ $line =~ 'className=' ]];
                  then
                   echo  -n "$line">>/tmp/tmpcase2
                  fi
                  if [[ $line =~ 'test=' ]];
                  then
                  echo   $line>>/tmp/tmpcase2
                  fi
                  done

                 cat /tmp/tmpcase2
                 cat /tmp/tmpcase2
                 for line in `cat /tmp/tmpcase2`
                 do
                 classname=`echo $line |awk -F 'className' '{print $2}'|awk -F '"' '{print $2}'`                                               
                 casename=`echo $line|awk -F 'test=' '{print $2}'|awk -F '"' '{print $2}'`                                                 

                 run_btft $casename $classname


                 done
#            fi
        else
            run_btft $1
        fi
        rm /tmp/tmpcase
        rm /tmp/tmpcase2

}

sedproject()
{
        git clone https://github.com/zhekunzhang/btft_hello.git 
       
        if [[ $1 == "hello.c" ]];then 
                config_gradle
                exit 0
        fi
        cp "$1" btft_hello/gradle_src/jni
        btftname=`echo $1|gawk -F\. '{print $1}'`
        sed -i "s/hello/$btftname/g"  btft_hello/gradle_src/jni/test.cpp
        sed -i "s/hello/$btftname/g"  btft_hello/gradle_src/jni/Android.mk
        sed -i "s/hello/$btftname/g"  btft_hello/gradle_src/AndroidManifest.xml
        sed -i "s/hello/$btftname/g"  btft_hello/gradle_src/src/com/intel/btft/hello/hello.java
        sed -i "s/hello/$btftname/g"  btft_hello/gradle_src/src/com/intel/btft/hello/testFTest.java
        sed -i "s/hello/$btftname/g"  btft_hello/gradle_src/settings.gradle
        functionname=`cat "$1" |grep "()"|gawk  '{print $2}'|gawk -F\( '{print $1}' ` 
        sed -i "s/btftmain/$functionname/g"  btft_hello/gradle_src/jni/test.cpp
        sed -i "s/btftmain/$functionname/g"  btft_hello/gradle_src/src/com/intel/btft/hello/hello.java
        mv btft_hello/gradle_src/src/com/intel/btft/hello/hello.java btft_hello/gradle_src/src/com/intel/btft/hello/$btftname.java
        mv btft_hello/gradle_src/src/com/intel/btft/hello btft_hello/gradle_src/src/com/intel/btft/$btftname
         mv btft_hello/ btft_$btftname


}



until [[ -z "$1" ]]
do
    count=$(($count+1))
    if [ $count -gt 20 ];then 
        echo "Please check input parms"
        exit 2
    fi
    if [[ "$1" =~ ".c" ]]
    then
        sedproject $1
        break
    elif [[ "$1" == "-n" ]]
    then
        shift
        rm $apk_name*.apk
        apk_name=$1
        project_name=$1
        package_name=`cat $project_name/gradle_src/AndroidManifest.xml|grep package|head -n 1|awk -F 'package' '{print $2}'|awk -F '"' '{print $2}' ` 
        shift
    elif [[ "$1" == "-a" ]]
    then
        shift
        switch_abi $1
        build_apk_type $1
        shift
    elif [[ "$1" == "-r" ]]
    then
        shift
        if [[ "$1" == "all"  ]];then
            #run_btft_case $project_name
            run_btft_case all 
        else
            run_btft_case $1  
        fi
        shift
    fi
done
if [[ "$package_name" != ""  ]];then
    adb -s emulator-5554 uninstall $package_name
fi
