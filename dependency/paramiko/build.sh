#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2019. All rights reserved
set -e
python $(pwd)/../../build/pull_open_source.py "paramiko" "paramiko-2.6.0.tar.gz" "05833MWY"
mkdir -p $(pwd)/../python-lib
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
TAR_SOURCE_FILE=paramiko-2.6.0.tar.gz
SOURCE_FILE=paramiko-2.6.0
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
python setup.py build
python setup.py install
cp -r build/lib*/* $TARGET_PATH
