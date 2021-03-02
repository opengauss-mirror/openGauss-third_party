#!/bin/bash
# Java-Core-Sdk lib installation.
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2021. All rights reserved.
# description: the script that make install java-core-sdk libs. it used for jdbc.
# date: 2021-01-08
# modified:
# version: 1.0
# history:
######################################################################
# Parameter setting
######################################################################
set -e

python $(pwd)/../../build/pull_open_source.py "javasdkcore" "java-sdk-core-3.0.12.jar" "05832USL"
LOCAL_PATH=${0}
FIRST_CHAR=$(expr substr "$LOCAL_PATH" 1 1)
if [ "$FIRST_CHAR" = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi
LOCAL_DIR=$(dirname "${LOCAL_PATH}")
ROOT_DIR="${LOCAL_DIR}/../../"
TARGET_PATH=${ROOT_DIR}/output/common/javasdkcore
[ -d ${TARGET_PATH} ] && rm -rf ${TARGET_PATH}/*
mkdir -pv ${TARGET_PATH}
cp -r ${LOCAL_DIR}/*.jar ${TARGET_PATH}
