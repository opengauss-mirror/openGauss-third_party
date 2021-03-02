#!/bin/bash
#######################################################################
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
# description: the script that make install netifaces
# version: 1.10.9
# date:
# history:
#######################################################################
set -e
python $(pwd)/../../build/pull_open_source.py "netifaces" "netifaces-release_0_10_9.tar.gz" "05833LEF"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
TAR_SOURCE_FILE=netifaces-release_0_10_9.tar.gz
SOURCE_FILE=netifaces-release_0_10_9
mkdir -p $TARGET_PATH/netifaces

tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
python setup.py build
python setup.py install
cp -r build/lib*/* $TARGET_PATH/netifaces
cp -r build/lib*/netifaces.so $TARGET_PATH/netifaces/netifaces.so_UCS4

cp ./../netifaces.py $TARGET_PATH/netifaces/netifaces.py
