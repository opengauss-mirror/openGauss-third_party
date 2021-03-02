#!/bin/bash
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
#sudo yum install -y libffi-devel
set -e
python $(pwd)/../../build/pull_open_source.py "cffi" "cffi-1.13.2.tar.gz" "05833NKG"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH:/usr/lib64
export PATH=$TARGET_PATH:$PATH
export PYTHONPATH=$TARGET_PATH:$LIBRARY_PATH
TAR_SOURCE_FILE=cffi-1.13.2.tar.gz
SOURCE_FILE=cffi-1.13.2
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
python setup.py build
PYTHONHASHSEED=0 python setup.py install
cp -r build/lib*/* $TARGET_PATH
cp -r $TARGET_PATH/_cffi_backend.so $TARGET_PATH/_cffi_backend.so_UCS4

cp ./../_cffi_backend.py $TARGET_PATH/_cffi_backend.py
