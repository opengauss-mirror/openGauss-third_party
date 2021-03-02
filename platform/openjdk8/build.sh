#!/bin/bash
#######################################################################
# Copyright (c): 2012-2022, Huawei Tech. Co., Ltd.
# description: construct huaweijdk
# version: 1.0.0
# history:
#######################################################################
set -e

SOURCE_FILE='jdk1.8.0_222'
rm -rf ./"${SOURCE_FILE}"

ARCH=$(uname -m)
IFS=$(echo -en "\n\b")
LOCAL_PATH=${0}
FIRST_CHAR_PATH=$(expr substr "$LOCAL_PATH" 1 1)
if [ "$FIRST_CHAR_PATH" = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi
LOCAL_DIR=$(dirname "${LOCAL_PATH}")
ROOT_DIR="${LOCAL_DIR}/../.."
PLANTFORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)
TARGET_PATH=${ROOT_DIR}/output/platform/${PLANTFORM_STR}/openjdk8
[ -d ${TARGET_PATH} ] && rm -rf ${TARGET_PATH}/*

mkdir -pv ${TARGET_PATH}

if [ ${ARCH} = "aarch64" ];then
    TAR_SOURCE_FILE="OpenJDK8U-jdk_aarch64_linux_8u222.tar.gz";
else
    TAR_SOURCE_FILE="OpenJDK8U-jdk_x64_linux_8u222.tar.gz";
fi

tar -zxvf "${TAR_SOURCE_FILE}"
cp -a ./"${SOURCE_FILE}" ${TARGET_PATH}
