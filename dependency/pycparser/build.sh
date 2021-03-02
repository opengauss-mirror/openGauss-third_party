#!/bin/bash
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
set -e
python $(pwd)/../../build/pull_open_source.py "pycparser" "pycparser-2.19.tar.gz" "05834AYE"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
export PYTHONPATH=$TARGET_PATH:$PYTHONPATH
TAR_SOURCE_FILE=pycparser-2.19.tar.gz
SOURCE_FILE=pycparser-2.19
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
python setup.py build
PYTHONHASHSEED=0 python setup.py install
cp -r build/lib*/* $TARGET_PATH

