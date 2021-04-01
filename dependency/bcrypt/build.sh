#!/bin/bash
#######################################################################
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
# description: the script that make install bcrypt
# version: 3.1.7
# date:
# history:
#######################################################################
set -e
python $(pwd)/../../build/pull_open_source.py "bcrypt" "bcrypt-3.1.7.tar.gz" "05833LMP"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
python_version=`python -V | awk -F ' ' '{print $2}' |awk -F '.' -v OFS='.' '{print $1,$2}'`
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
export PYTHONPATH=$TARGET_PATH:$PYTHONPATH
TAR_SOURCE_FILE=bcrypt-3.1.7.tar.gz
SOURCE_FILE=bcrypt-3.1.7
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
CFLAGS="-fstack-protector-strong -Wl,-z,relro,-z,now" python setup.py build
if [[ "$PLATFORM" == centos* ]]; then
    CPU_BIT=$(uname -m)
    if [ X"$CPU_BIT" = X"x86_64" ]; then
        gcc -pthread -shared -Wl,-z,relro,-z,now,-z,noexecstack -s -ftrapv -g build/temp.linux-x86_64-$python_version/build/temp.linux-x86_64-$python_version/_bcrypt.o build/temp.linux-x86_64-$python_version/src/_csrc/blf.o build/temp.linux-x86_64-$python_version/src/_csrc/bcrypt.o build/temp.linux-x86_64-$python_version/src/_csrc/bcrypt_pbkdf.o build/temp.linux-x86_64-$python_version/src/_csrc/sha2.o build/temp.linux-x86_64-$python_version/src/_csrc/timingsafe_bcmp.o  -o build/lib.linux-x86_64-$python_version/bcrypt/_bcrypt.abi3.so
    fi
fi
python setup.py install
cp -r build/lib*/* $TARGET_PATH
cp ../_bcrypt.py $TARGET_PATH/bcrypt/
