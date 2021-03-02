#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install brotli
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
set -e
python $(pwd)/../../build/pull_open_source.py "brotli" "brotli-1.0.7.tar.gz" "05833HGN"

LOCAL_PATH=${0}
FIRST_CHAR=$(expr substr "$LOCAL_PATH" 1 1)
if [ "$FIRST_CHAR" = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi

LOCAL_DIR=$(dirname "${LOCAL_PATH}")
export PACKAGE=brotli-1.0.7
[ -n "${PACKAGE}" ] && rm -rf ${PACKAGE}
tar -xvf $PACKAGE.tar.gz
#unzip $PACKAGE.zip
#rm -rf $PACKAGE.tar.gz
#rm -rf $PACKAGE.zip
cd $PACKAGE
mkdir out
cd out
../configure-cmake  --disable-debug  --prefix=${LOCAL_DIR}/install_comm
make -j4
make install
