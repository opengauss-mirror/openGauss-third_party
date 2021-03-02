#!/bin/bash
# Perform PL/Java lib installation.
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install pljava libs
# date: 2019-5-16
# modified:
# version: 1.0
# history:
######################################################################
# Parameter setting
######################################################################
set -e

python $(pwd)/../../build/pull_open_source.py "slf4j" "slf4j-api-1.7.30.jar" "05834BMW"
LOCAL_PATH=${0}
FIRST_CHAR=$(expr substr "$LOCAL_PATH" 1 1)
if [ "$FIRST_CHAR" = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi
LOCAL_DIR=$(dirname "${LOCAL_PATH}")
ROOT_DIR="${LOCAL_DIR}/../../"
INSTALL_COMPONENT_PATH_NAME=${ROOT_DIR}/output/common/slf4j
[ -d ${INSTALL_COMPONENT_PATH_NAME} ] && rm -rf ${INSTALL_COMPONENT_PATH_NAME}/*
mkdir -pv ${INSTALL_COMPONENT_PATH_NAME}
cp -r ${LOCAL_DIR}/*.jar ${INSTALL_COMPONENT_PATH_NAME}

