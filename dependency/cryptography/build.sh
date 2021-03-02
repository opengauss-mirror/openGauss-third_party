#!/bin/bash
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
set -e
python $(pwd)/../../build/pull_open_source.py "cryptography" "cryptography-2.9.tar.gz" "05834YEF"
mkdir -p $(pwd)/../python-lib
PLATFORM=$(bash $(pwd)/../../build/get_PlatForm_str.sh)
mkdir -p $(pwd)/../../output/dependency/install_tools_$PLATFORM
export TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM
export OPENSSL_ROOT_DIR=$(pwd)/../../output/dependency/$PLATFORM/openssl/comm
export LD_LIBRARY_PATH=$TARGET_PATH:$LD_LIBRARY_PATH
export LIBRARY_PATH=${OPENSSL_ROOT_DIR}/lib:$LIBRARY_PATH
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$OPENSSL_ROOT_DIR/include
TAR_SOURCE_FILE=cryptography-2.9.tar.gz
SOURCE_FILE=cryptography-2.9
tar zxvf $TAR_SOURCE_FILE
cd $SOURCE_FILE
CFLAGS="-Wl,-z,relro,-z,now -s" python setup.py build_ext --inplace --library-dirs=${OPENSSL_ROOT_DIR}/lib --include-dirs=${OPENSSL_ROOT_DIR}/include
python setup.py install
cp -r build/lib*/* $TARGET_PATH
