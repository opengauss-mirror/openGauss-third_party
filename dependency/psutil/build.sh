#!/bin/bash
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
set -e
python $(pwd)/../../build/pull_open_source.py "psutil" "psutil-5.6.1.tar.gz" "05834AVD"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
TAR_SOURCE_FILE=psutil-5.6.1.tar.gz
SOURCE_FILE=psutil-5.6.1
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
patch -p1 < ../psutil_huawei.patch
python setup.py build
python setup.py install
cp -r build/lib*/* $TARGET_PATH
# add boost script
cp ../_psutil_linux.py $TARGET_PATH/psutil/
cp ../_psutil_posix.py $TARGET_PATH/psutil/
