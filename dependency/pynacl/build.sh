#!/bin/bash
#######################################################################
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
# description: the script that make install pynacl
# version: 1.3.0
# date:
# history:
#######################################################################
set -e
python $(pwd)/../../build/pull_open_source.py "pynacl" "pynacl-1.3.0.tar.gz" "05833ABT"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
python_version=`python -V | awk -F ' ' '{print $2}' |awk -F '.' -v OFS='.' '{print $1,$2}'`
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
TAR_SOURCE_FILE=pynacl-1.3.0.tar.gz
SOURCE_FILE=pynacl-1.3.0
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
CFLAGS="-fstack-protector-strong -Wl,-z,relro,-z,now" python setup.py build
if [[ "$PLATFORM" == centos* ]]; then
    CPU_BIT=$(uname -m)
    if [ X"$CPU_BIT" = X"x86_64" ]; then
        gcc -pthread -shared -Wl,-z,relro,-z,now,-z,noexecstack -s -ftrapv -g build/temp.linux-x86_64-$python_version/build/temp.linux-x86_64-$python_version/_sodium.o -Lbuild/temp.linux-x86_64-$python_version/lib -Lbuild/temp.linux-x86_64-$python_version/lib64 -Lbuild/temp.linux-x86_64-$python_version -lsodium -lsodium -o build/lib.linux-x86_64-$python_version/nacl/_sodium.abi3.so
    fi
fi
python setup.py install
cp -r build/lib*/* $TARGET_PATH
# add boost script
cp ../_sodium.py $TARGET_PATH/nacl/
