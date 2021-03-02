#!/bin/bash
# Perform PL/Java lib installation.
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
#  description: the script that make install pljava libs
#  date: 2019-5-16
#  modified: 
#  version: 1.0
#  history:

######################################################################
# Parameter setting
######################################################################
LOCAL_PATH=${0}
FIRST_CHAR="$(expr substr "$LOCAL_PATH" 1 1)"
if [ "$FIRST_CHAR" = "/" ]; then
    LOCAL_PATH=${0}
elif [ ${LOCAL_PATH:0:2} = "./" ]; then
    LOCAL_PATH="$(pwd)/${LOCAL_PATH:2}"
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi

LOCAL_DIR="$(dirname "${LOCAL_PATH}")"
CONFIG_FILE_NAME=config.ini
BUILD_OPTION=release
ICE_SOURCE_CODE_PATH=pljava_1.5.2_src
ZIP_FILE_NAME=${ICE_SOURCE_CODE_PATH}.zip
SOURCE_CODE_PATH=pljava-1_5_2
TAR_FILE_NAME=${SOURCE_CODE_PATH}.tar.gz
LOG_FILE=${LOCAL_DIR}/pljava-1_5_2.log
BUILD_PATH=build
BUILD_FAILED=1
TOP_DIR="${PWD}/../.."
ls ${LOCAL_DIR}/${CONFIG_FILE_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    die "[Error] the file ${CONFIG_FILE_NAME} not exist."
fi

COMPLIE_TYPE_LIST="$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $2}' | sed 's/|/ /g')"
COMPONENT_NAME="$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $1}' | awk -F '@' '{print $2}')"
COMPONENT_TYPE="$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '@' '{print $1}')"
PLAT_FORM_STR="$(bash ${TOP_DIR}/build/get_PlatForm_str.sh)"

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


ROOT_DIR="${LOCAL_DIR}/../../../"
INSTALL_COMPONENT_PATH_NAME="${LOCAL_DIR}/${COMPONENT_NAME}"

#######################################################################
## print help information
#######################################################################
function print_help()
{
    echo "Usage: $0 [OPTION]
    -h|--help           show help information
    -m|--build_option   provide type of operation, values of paramenter is all, build, shrink, dist or clean"
}

#######################################################################
#  Print log.
#######################################################################
log()
{
    echo "[Build pljava] "$(date +%y-%m-%d" "%T)": $@"
    echo "[Build pljava] "$(date +%y-%m-%d" "%T)": $@" >> "$LOG_FILE" 2>&1
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
