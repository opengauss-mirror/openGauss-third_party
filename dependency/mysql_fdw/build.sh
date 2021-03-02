#!/bin/bash
#  Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
#  description: the script that make install lz4
#  date: 2020-12-16
#  version: 1.0
#  history:
#    2020-12-16 first version

set -e

python $(pwd)/../../build/pull_open_source.py "mysql_fdw" "mysql_fdw-REL-2_5_5.tar.gz" "05837EYW"

LOCAL_PATH=${0}
FIRST_CHAR=$(expr substr "$LOCAL_PATH" 1 1)
if [ "$FIRST_CHAR" = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi
LOCAL_DIR=$(dirname "${LOCAL_PATH}")
ROOT_DIR="${LOCAL_DIR}/../../"
TARGET_PATH=${ROOT_DIR}/output/dependency/mysql_fdw
[ -d ${TARGET_PATH} ] && rm -rf ${TARGET_PATH}/*
mkdir -pv ${TARGET_PATH}
cp -r ${LOCAL_DIR}/* ${TARGET_PATH}