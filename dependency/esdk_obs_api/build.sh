#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# description: the script that make install libobs
# date: 2020-04-11
# version: 3.1.3
# history:
# 2020-04-11 upgrade to huaweicloud-sdk-c-obs-3.1.3.tar.gz
set -e

######################################################################
# Parameter setting
######################################################################
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

TAR_FILE_NAME=huaweicloud-sdk-c-obs-3.1.3.tar.gz
SOURCE_CODE_PATH=huaweicloud-sdk-c-obs-3.1.3

LOG_FILE=${LOCAL_DIR}/build_obs.log
BUILD_FAILED=1

#######################################################################
#  Print log.
#######################################################################
log() {
    printf "[Build libobs] $(date +%y-%m-%d): $@"
    echo "[Build libobs] $(date +%y-%m-%d): $@" >> "$LOG_FILE" 2>&1
}

#######################################################################
#  print log and exit.
#######################################################################
die() {
    log "$@"
    echo "$@"
    exit $BUILD_FAILED
}

ls ${LOCAL_DIR}/${CONFIG_FILE_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    die "[Error] the file ${CONFIG_FILE_NAME} not exist."
fi

COMPLIE_TYPE_LIST=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $2}' | sed 's/|/ /g')
COMPONENT_NAME=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $1}' | awk -F '@' '{print $2}')
COMPONENT_TYPE=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '@' '{print $1}')
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)

if [ "${PLAT_FORM_STR}"X = "Failed"X ]; then
    die "[Error] the platform is not supported!"
fi

if [ "${COMPONENT_NAME}"X = ""X ]; then
    die "[Error] get component name failed!"
fi

if [ "${COMPONENT_TYPE}"X = ""X ]; then
    die "[Error] get component type failed!"
fi

ROOT_DIR="${LOCAL_DIR}/../../../"
INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/${COMPONENT_TYPE}/${PLAT_FORM_STR}/${COMPONENT_NAME}"

#######################################################################
## print help information
#######################################################################
function print_help() {
    echo "Usage: $0 [OPTION]
        -h|--help               show help information
        -m|--build_option       provode type of operation, values of paramenter is build, shrink, dist or clean
    "
}

#######################################################################
# build and install component
#######################################################################
function build_component() {
    cd ${LOCAL_DIR}
    [ -e ${SOURCE_CODE_PATH} ] && rm -rf ${SOURCE_CODE_PATH}
    tar -xvf ${TAR_FILE_NAME}

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to ${LOCAL_DIR}/${SOURCE_CODE_PATH} failed."
    fi
    log "[Notice] add patch..."
    patch -Np1 < ${LOCAL_DIR}/huawei_obs_new_alt_new.patch
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] obs Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] obs not supported build type."
                ;;
            debug)
                die "[Error] obs not supported build type."
                ;;
            release_llt)
                die "[Error] obs not supported build type."
                ;;
            debug_llt)
                die "[Error] obs not supported build type."
                ;;
            comm)
                sed -i '123c make -j4' ${LOCAL_DIR}/${SOURCE_CODE_PATH}/source/eSDK_OBS_API/eSDK_OBS_API_C++/build.sh
                sed -i '128c make -j4' ${LOCAL_DIR}/${SOURCE_CODE_PATH}/source/eSDK_OBS_API/eSDK_OBS_API_C++/build.sh
                cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}/source/eSDK_OBS_API/eSDK_OBS_API_C++/
                sh build.sh obs >> ${LOG_FILE} 2>&1
                if [ $? -ne 0 ]; then
                    log "[Error] build obs fail..."
                    exit 1
                fi
                log "[Info] Successfully installed libobs into"
                log "[Info] Copying lib..."
                install_comm=${LOCAL_DIR}/install_comm
                mkdir -p ${install_comm}/include
                mkdir -p ${install_comm}/lib
                install_llt=${LOCAL_DIR}/install_llt
                mkdir -p ${install_llt}/include
                mkdir -p ${install_llt}/lib
                # copy securec lib to libos
                cp -rf ${LOCAL_DIR}/${SOURCE_CODE_PATH}/platform/huaweisecurec/include/* ${install_comm}/include/
                cp -rf ${LOCAL_DIR}/${SOURCE_CODE_PATH}/platform/huaweisecurec/lib/* ${install_comm}/lib/
                # copy liblog4cpp to libobs
                cp ${LOCAL_DIR}/${SOURCE_CODE_PATH}/platform/eSDK_LogAPI_V2.1.10/C/linux_64/libeSDKLogAPI.so ${install_comm}/lib/
                cp ${LOCAL_DIR}/${SOURCE_CODE_PATH}/platform/eSDK_LogAPI_V2.1.10/log4cpp/install_comm/lib/liblog4cpp.so ${install_comm}/lib/
                cp ${LOCAL_DIR}/${SOURCE_CODE_PATH}/platform/eSDK_LogAPI_V2.1.10/log4cpp/install_comm/lib/liblog4cpp.so.5 ${install_comm}/lib/
                cp ${LOCAL_DIR}/${SOURCE_CODE_PATH}/platform/eSDK_LogAPI_V2.1.10/log4cpp/install_comm/lib/liblog4cpp.so.5.0.6 ${install_comm}/lib/
                # copy pcre lib to libobs
                cp ${LOCAL_DIR}/../pcre/install_comm/lib/libpcre.so ${install_comm}/lib/
                cp ${LOCAL_DIR}/../pcre/install_comm/lib/libpcre.so.1 ${install_comm}/lib/
                cp ${LOCAL_DIR}/../pcre/install_comm/lib/libpcre.so.1.2.10 ${install_comm}/lib/
                # copy libiconv lib to libobs
                cp ${LOCAL_DIR}/../libiconv/install_comm/lib/libcharset.so ${install_comm}/lib/
                cp ${LOCAL_DIR}/../libiconv/install_comm/lib/libcharset.so.1 ${install_comm}/lib/
                cp ${LOCAL_DIR}/../libiconv/install_comm/lib/libcharset.so.1.0.0 ${install_comm}/lib/
                cp ${LOCAL_DIR}/../libiconv/install_comm/lib/libiconv.so ${install_comm}/lib/
                cp ${LOCAL_DIR}/../libiconv/install_comm/lib/libiconv.so.2 ${install_comm}/lib/
                cp ${LOCAL_DIR}/../libiconv/install_comm/lib/libiconv.so.2.6.0 ${install_comm}/lib/
                cp ${LOCAL_DIR}/../libiconv/install_comm/lib/preloadable_libiconv.so ${install_comm}/lib/
                # copy nghttp2 lib to libobs
                cp ${LOCAL_DIR}/../nghttp2/install_comm/lib/libnghttp2.so ${install_comm}/lib/
                cp ${LOCAL_DIR}/../nghttp2/install_comm/lib/libnghttp2.so.14 ${install_comm}/lib/
                cp ${LOCAL_DIR}/../nghttp2/install_comm/lib/libnghttp2.so.14.18.0 ${install_comm}/lib/
                # copy libxml2 lib to libobs
                cp ${LOCAL_DIR}/../libxml2/install_comm/lib/libxml2.so ${install_comm}/lib/
                cp ${LOCAL_DIR}/../libxml2/install_comm/lib/libxml2.so.2 ${install_comm}/lib/
                cp ${LOCAL_DIR}/../libxml2/install_comm/lib/libxml2.so.2.9.9 ${install_comm}/lib/
                # copy libobs to install dir
                cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}/source/eSDK_OBS_API/eSDK_OBS_API_C++
                cp OBS.ini ${install_comm}/lib/
                cd ./build
                cp ./include/eSDKOBS.h ${install_comm}/include/
                cp ./lib/libeSDKOBS.so ${install_comm}/lib/
                cp -rf ${install_comm}/* ${install_llt}/
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac
    done
}

#######################################################################
# choose the real files
#######################################################################
function shrink_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            release) ;;

            comm)
                mkdir -p ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist
                cp -rf ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp ${LOCAL_DIR}/${SOURCE_CODE_PATH}/stage/lib/* ${LOCAL_DIR}/install_llt_dist/lib\" failed."
                fi
                ;;
            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] obs shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#	we could makesure that $install_comm is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${install}/comm\" failed."
                fi
                ;;
            llt)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/llt/*
                cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_llt_dist/* ${install}/llt\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] obs dist using \"${COMPILE_TYPE}\" has been finished!"
    done
}

#######################################################################
# clean component
#######################################################################
function clean_component() {
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR}/${SOURCE_CODE_PATH} failed."
    fi

    cd ${LOCAL_DIR}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR} failed."
    fi
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf ${SOURCE_CODE_PATH}
    rm -rf install_*

    log "[Notice] obs clean has been finished!"
}
#######################################################################
#######################################################################
#######################################################################
# main
#######################################################################
#######################################################################
#######################################################################
function main() {
    case "${BUILD_OPTION}" in
        build)
            build_component
            ;;
        shrink)
            shrink_component
            ;;
        dist)
            dist_component
            ;;
        clean)
            clean_component
            ;;
        all)
            build_component
            shrink_component
            dist_component
            #clean_component
            ;;
        *)
            log "Internal Error: option processing error: $2"
            log "please input right paramenter values build, shrink, dist or clean "
            ;;
    esac
}

########################################################################
if [ $# = 0 ]; then
    log "missing option"
    print_help
    exit 1
fi

##########################################################################
#read command line paramenters
##########################################################################
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            print_help
            exit 1
            ;;
        -m | --build_option)
            if [ "$2"X = X ]; then
                die "no given version number values"
            fi
            BUILD_OPTION=$2
            shift 2
            ;;
        *)
            log "Internal Error: option processing error: $1" 1>&2
            log "please input right paramtenter, the following command may help you"
            log "./build.sh --help or ./build.sh -h"
            exit 1
            ;;
    esac
done

###########################################################################
main
