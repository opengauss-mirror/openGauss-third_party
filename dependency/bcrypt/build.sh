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
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
export PYTHONPATH=$TARGET_PATH:$PYTHONPATH
TAR_SOURCE_FILE=bcrypt-3.1.7.tar.gz
SOURCE_FILE=bcrypt-3.1.7
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
python setup.py build
python setup.py install
cp -r build/lib*/* $TARGET_PATH
cp ../_bcrypt.py $TARGET_PATH/bcrypt/
