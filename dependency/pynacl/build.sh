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
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
TAR_SOURCE_FILE=pynacl-1.3.0.tar.gz
SOURCE_FILE=pynacl-1.3.0
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
python setup.py build
python setup.py install
cp -r build/lib*/* $TARGET_PATH
# add boost script
cp ../_sodium.py $TARGET_PATH/nacl/
