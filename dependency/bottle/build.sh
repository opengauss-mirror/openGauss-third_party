#!/bin/bash
#######################################################################
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
# description: the script that make install bottle
# version: 0.12.17
# date:
# history:
#######################################################################
set -e
python $(pwd)/../../build/pull_open_source.py "bottle" "bottle-0.12.17-src.zip" "05833NDF"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM/bottle
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
ZIP_SOURCE_FILE=bottle-0.12.17-src.zip
TAR_SOURCE_FILE=bottle-0.12.17.tar.gz
SOURCE_FILE=bottle-0.12.17
unzip -o $ZIP_SOURCE_FILE
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
python setup.py build
sed -i "s/scripts=/#scripts=/g" setup.py
python setup.py install
mkdir -p $TARGET_PATH
cp -r build/lib*/* $TARGET_PATH
touch $TARGET_PATH/__init__.py
