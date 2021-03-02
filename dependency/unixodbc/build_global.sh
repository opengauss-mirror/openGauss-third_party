#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2019. All rights reserved.
# description: the script that make install unixODBC
# date: 2019-12-28
# version: 1.1
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
CONFIG_FILE_NAME=config.ini
BUILD_OPTION=release 
TAR_FILE_NAME=unixODBC-2.3.9.tar.gz
SOURCE_CODE_PATH=unixODBC-2.3.9
LOG_FILE=${LOCAL_DIR}/build_unixODBC.log
BUILD_FAILED=1


#######################################################################
## print help information
#######################################################################
function print_help()
{
    echo "Usage: $0 [OPTION]
    -h|--help               show help information
    -m|--build_option       provode type of operation, values of paramenter is build, shrink, dist or clean
    "
}

#######################################################################
#  Print log.
#######################################################################
log()
{
    echo "[Build unixODBC] $(date +%y-%m-%d' '%T): $@"
    echo "[Build unixODBC] $(date +%y-%m-%d' '%T): $@" >> "$LOG_FILE" 2>&1
}

#######################################################################
#  print log and exit.
#######################################################################
die()
{
    log "$@"
    echo "$@"
    exit $BUILD_FAILED
}

ls ${LOCAL_DIR}/${CONFIG_FILE_NAME} >/dev/null 2>&1
if [ $? -ne 0 ]; then
    die "[Error] the file ${CONFIG_FILE_NAME} not exist."
fi

COMPLIE_TYPE_LIST=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $2}' | sed  's/|/ /g')
COMPONENT_NAME=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' |awk -F '=' '{print $1}'| awk -F '@' '{print $2}')
COMPONENT_TYPE=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '@' '{print $1}')
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)

if [ "${PLAT_FORM_STR}"X = "Failed"X ]
then
    die "[Error] the plat form is not supported!"
fi

if [ "${COMPONENT_NAME}"X = ""X ]
then
    die "[Error] get component name failed!"
fi

if [ "${COMPONENT_TYPE}"X = ""X ]
then
    die "[Error] get component type failed!"
fi

if [ "${PLAT_FORM_STR}" = "deepin15.2_aarch64" ]
then
    BUILD_TYPE=aarch64-unknown-linux-gnu
    BUILD_TYPE_OPTION="--build=${BUILD_TYPE}"
fi

ROOT_DIR="${LOCAL_DIR}/../../"
#INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/${COMPONENT_TYPE}/${PLAT_FORM_STR}/${COMPONENT_NAME}"
INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/output/dependency/install_tools_${PLAT_FORM_STR}/${COMPONENT_NAME}"
