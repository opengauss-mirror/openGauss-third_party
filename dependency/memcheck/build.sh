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

LOCAL_PATH=${0}
FIRST_CHAR=$(expr substr "$LOCAL_PATH" 1 1)
if [ "$FIRST_CHAR" = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi
LOCAL_DIR=$(dirname "${LOCAL_PATH}")
ROOT_DIR="${LOCAL_DIR}/../../"
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)
TARGET_PATH=${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/memcheck
[ -d ${TARGET_PATH} ] && rm -rf ${TARGET_PATH}/*
mkdir -pv ${TARGET_PATH}
cp -r ${LOCAL_DIR}/${PLAT_FORM_STR}/* ${TARGET_PATH}
