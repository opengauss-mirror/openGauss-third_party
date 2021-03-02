#!/bin/bash
#######################################################################
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
# description: the script that make install asn1crypto
# version: 1.2.0
# date: 
# history:
#######################################################################
set -e
python $(pwd)/../../build/pull_open_source.py "asn1crypto" "asn1crypto-1.2.0.tar.gz" "05833TCM"
PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export PATH=$TARGET_PATH:$PATH
TAR_SOURCE_FILE=asn1crypto-1.2.0.tar.gz
SOURCE_FILE=asn1crypto-1.2.0
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
python setup.py build
python setup.py install
cp -r build/lib*/* $TARGET_PATH
