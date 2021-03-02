#!/bin/bash
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
set -e
python $(pwd)/../../build/pull_open_source.py "psutil" "psutil-5.6.1.tar.gz" "05834AVD"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
python_version=`python -V | awk -F ' ' '{print $2}' |awk -F '.' -v OFS='.' '{print $1,$2}'`
file_name=${python_version/./}m
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
TAR_SOURCE_FILE=psutil-5.6.1.tar.gz
SOURCE_FILE=psutil-5.6.1
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
patch -p1 < ../psutil_huawei.patch
python setup.py build
if [[ "$PLATFORM" == centos* ]]; then
    CPU_BIT=$(uname -m)
    if [ X"$CPU_BIT" = X"x86_64" ]; then
        gcc -pthread -shared -Wl,-z,relro,-z,now,-z,noexecstack -s -ftrapv -g build/temp.linux-x86_64-$python_version/psutil/_psutil_common.o build/temp.linux-x86_64-$python_version/psutil/_psutil_posix.o build/temp.linux-x86_64-$python_version/psutil/_psutil_linux.o  -o build/lib.linux-x86_64-$python_version/psutil/_psutil_linux.cpython-$file_name-x86_64-linux-gnu.so
        gcc -pthread -shared -Wl,-z,relro,-z,now,-z,noexecstack -s -ftrapv -g build/temp.linux-x86_64-$python_version/psutil/_psutil_common.o build/temp.linux-x86_64-$python_version/psutil/_psutil_posix.o  -o build/lib.linux-x86_64-$python_version/psutil/_psutil_posix.cpython-$file_name-x86_64-linux-gnu.so
    fi
fi
python setup.py install
cp -r build/lib*/* $TARGET_PATH
# add boost script
cp ../_psutil_linux.py $TARGET_PATH/psutil/
cp ../_psutil_posix.py $TARGET_PATH/psutil/

cp -f $TARGET_PATH/psutil/_psutil_linux.*.so $TARGET_PATH/psutil/_psutil_linux.so_3.6
if [ $? -ne 0 ]; then
    die "[Error] \"cp -f $TARGET_PATH/psutil/_psutil_linux.*.so $TARGET_PATH/psutil/_psutil_linux.so_3.6\" failed."
fi
mv $TARGET_PATH/psutil/_psutil_linux.*.so $TARGET_PATH/psutil/_psutil_linux.so_3.7
if [ $? -ne 0 ]; then
    die "[Error] \"mv $TARGET_PATH/_psutil_linux.*.so $TARGET_PATH/psutil/_psutil_linux.so_3.7\" failed."
fi
cp -f $TARGET_PATH/psutil/_psutil_posix.*.so $TARGET_PATH/psutil/_psutil_posix.so_3.6
if [ $? -ne 0 ]; then
    die "[Error] \"cp -f $TARGET_PATH/psutil/_psutil_posix.*.so $TARGET_PATH/psutil/_psutil_posix.so_3.6\" failed."
fi
mv $TARGET_PATH/psutil/_psutil_posix.*.so $TARGET_PATH/psutil/_psutil_posix.so_3.7
if [ $? -ne 0 ]; then
    die "[Error] \"mv $TARGET_PATH/psutil/_psutil_posix.*.so $TARGET_PATH/psutil/_psutil_posix.so_3.7\" failed."
fi