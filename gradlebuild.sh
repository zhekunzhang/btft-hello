#!/bin/bash
#set -x 
if [[ $# -lt 1 ]]
then
    clear
    echo "下载hello project 示例  并配置环境"
    echo "  ./gradlebuild.sh hello.c"
    echo "  ./gradlebuild.sh [projectname].c"
    echo ""
    echo ""
    echo ""
    echo "generate apk"
    echo "  ./gradlebuild.sh  -a ( arm32 / arm64 /x86 / x64 ) -t  btft_hello"
    echo ""
    echo "run one case"
    echo "  ./gradlebuild.sh  -a arm32  -t  btft_aeabitest   -r AeabiMemset4Test"
    echo ""
    echo "run all case"
    echo "  ./gradlebuild.sh  -a arm32  -r all -t btft_hello"
    echo ""
    echo "run subdir case"
    echo "  ./gradlebuild.sh  -a arm32  -r all -t btft_libcExtension  -s ext01 "
    echo ""
    echo ""
    echo ""
    echo "替换ndk    source  ./gradlebuild.sh -t  btft_hello -a arm32  -r all"
exit
fi


count=0
curpath=$PWD
config_gradle()
{
    cd /home/test/bin
    cat ~/.bashrc|grep gradle-2.2> /dev/null 2>&1
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
            abi_type="arm32"
        elif [ "$1" == "arm64" ]; then
            abi_type="aarch64"
        elif [ "$1" == "x86" ]; then
            abi_type="x86"
        elif  [ "$1" == "x86_64" ]; then
            abi_type="x86_64"
        elif [ "$1" == "link" ];then
            cd $projectsrc_name/jni
            if [[ $? != 0 ]];then
                  echo "please check project name"
                     exit 2
            fi
            ln -sf "Application.mk."$abi_type   Application.mk
        fi
        cd "$curpath"
}


sourcesrc()
{
#ready for the bashrc of differnt version 
cd $curpath/$apk_name/gradle_src
if [[ -f ndk_config ]];
then
ndkversion=`cat ndk_config|grep :|head -n 1|awk -F 'r'  '{print$2}'`
else
cd $curpath/$apk_name/gradle_src/$subdir
ndkversion=`cat ndk_config|grep :|head -n 1|awk -F 'r'  '{print$2}'`
fi

echo $ndkversion
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
        sourcesrc
        cd $curpath/$apk_name/gradle_src
        if [[ -f AndroidManifest.xml  ]];then        
        echo `pwd`
        else
        cd $curpath/$apk_name/gradle_src/$subdir
        fi
        rm -rf build&&rm -rf libs&&rm -rf obj
        echo "ready build ..."
        gradle build   > /dev/null 2>&1
        ls
        cd "build/outputs/apk"
        cp *debug.apk $curpath
        if [[ -d $curpath/$apk_name/test/$abi_type/apk ]];then
        cp *debug.apk  $curpath/$apk_name/test/$abi_type/apk
        else
        cp *debug.apk  $curpath/$apk_name/test/$abi_type/$subdir/apk
        fi
        cd "$curpath";#cd $projectsrc_name;rm -rf build&&rm -rf libs&&rm -rf obj
        cd "$curpath"
}

run_btft()
{
#adb -s emulator-5554 shell -n am instrument -w -e class $package_name.$2\#$1 $package_name/android.test.InstrumentationTestRunner> /dev/null 2>&1
    adb -s emulator-5554 shell -n am instrument -w -e class $package_name.$2\#$1 $package_name/android.test.InstrumentationTestRunner> /tmp/result
    cat  /tmp/result|  grep 'OK' >& /dev/null        
    if [[ $? == 0  ]]
    then 
    echo "$1 run pass"
    else
    echo "$1 run fail"
    fi

}

run_btft_case()
{
        if [[ "$subdir"  ]];then
            cd $apk_name/test/$abi_type/$subdir/apk;adb -s emulator-5554 install -r  `ls *debug.apk` >/dev/null 2>&1
        else
        cd $apk_name/test/$abi_type/apk;adb -s emulator-5554 install -r  `ls *debug.apk` >/dev/null 2>&1        
        if [[ $? != 0 ]];then
                echo "Please generate apk first"
                exit 2
        fi
        fi

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
                 rm /tmp/tmpcase > /dev/null 2>&1
                 if [[  "$subdir" ]];then 
                 cd $curpath                 
                 cat `ls $apk_name/test/$abi_type/$subdir/*xml|head -n 1`|grep TestCase >>/tmp/tmpcase      
                 elif [[ -z "$subdir"  ]];then
                 cd $curpath;
                 cat `ls $apk_name/test/$abi_type/*xml|head -n 1`|grep TestCase >>/tmp/tmpcase
                 if [[ -d $project_name  ]];then
                 cat `ls $project_name/*xml|head -n 1`|grep TestCase >>/tmp/tmpcase      
                 else
                 cat `ls $project_name/../aarch64/*xml|head -n 1`|grep TestCase >>/tmp/tmpcase      
                 fi
                 fi
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
                 echo "============================="
                 echo "RUN SUBCASE RESULT "
                 echo "============================="
                 echo ""
                 echo ""
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
        rm /tmp/tmpcase >/dev/null 2>&1
        rm /tmp/tmpcase2 > /dev/null 2>&1

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



if  [[ "$1" =~ ".c" ]];then
sedproject $1
exit
fi


until [[ -z "$1" ]]
do
    if [[ "$1" == "-t" ]]
    then
        shift
        apk_name=$1
        project_name=$1
        shift
    elif [[ "$1" == "-a" ]]
    then
        shift
        abitype=$1 
        shift
    elif [[ "$1" == "-r" ]]
    then
        shift
        if [[ "$1" == "all"  ]];then 
        runcase="runall"
        else
        runcase="$1"
        fi
        shift
    elif [[ "$1" == "-s" ]]
    then
        shift
        subdir=$1
        shift
    elif [[ "$1" == "-b" ]]
    then
        shift
        branch=$1
        shift
    fi
done

switch_abi $abitype
rm $apk_name*.apk
if [[ "$subdir" ]];then 
tmpdirname=$project_name
project_name="$tmpdirname/test/$abi_type/$subdir"
projectsrc_name="$tmpdirname/gradle_src/$subdir"
else
tmpdirname=$project_name
project_name="$tmpdirname/test/$abi_type"
projectsrc_name="$tmpdirname/gradle_src"
fi
echo `pwd`
echo "$projectsrc_name"
package_name=`cat $projectsrc_name/AndroidManifest.xml|grep package|head -n 1|awk -F 'package'     '{print $2}'|awk -F '"' '{print $2}' ` 
if [[ $? != 0 ]];then 
echo "\n\n\n\n pelease input subdir"
ls $project_name
exit
fi
adb -s emulator-5554 uninstall $package_name >/dev/null
switch_abi link
build_apk_type $abitype
if [[ "$runcase" == "runall"  ]];then
run_btft_case all
else
run_btft_case $runcase
fi
if [[ "$package_name" != ""  ]];then
    adb -s emulator-5554 uninstall $package_name >/dev/null
fi
cd $curpath;rm *.apk
