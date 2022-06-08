#!/bin/bash
cd /home/test/bin
cat ~/.bashrc|grep gradle-2.2
if [ $? != 0 ];then
echo "export PATH=/home/test/bin/gradle-2.2/bin:\$PATH">>~/.bashrc
fi
source ~/.bashrc



if [ -d  gradle-2.2 ];then
        echo "存在"
        else
        wget  https://services.gradle.org/distributions/gradle-2.2-all.zip
        unzip gradle-2.2-all.zip
fi

