#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2020. All rights reserved.
#  description: the script that make install memcheck libs
#  date: 2015-9-15
#  version: 1.0
#  history:

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
LOG_FILE=${LOCAL_DIR}/build_memecheck.log
BUILD_FAILED=1

ls ${LOCAL_DIR}/${CONFIG_FILE_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    die "[Error] the file ${CONFIG_FILE_NAME} not exist."
fi

COMPLIE_TYPE_LIST=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $2}' | sed 's/|/ /g')
COMPONENT_NAME=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $1}' | awk -F '@' '{print $2}')
COMPONENT_TYPE=$(cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '@' '{print $1}')
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)

if [ "${PLAT_FORM_STR}"X = "Failed"X ]; then
    die "[Error] the plat form is not supported!"
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
        -m|--build_option       provide type of operation, values of paramenter is build, shrink, dist or clean
"
}

#######################################################################
#  Print log.
#######################################################################
log() {
    echo "[Copy memcheck libs] $(date +%y-%m-%d" "%T): $@"
    echo "[Copy memcheck libs] $(date +%y-%m-%d" "%T): $@" >> "$LOG_FILE" 2>&1
}

#######################################################################
#  print log and exit.
#######################################################################
die() {
    log "$@"
    echo "$@"
    exit $BUILD_FAILED
}

#######################################################################
# build and install component
#######################################################################
function build_component() {
    cd ${LOCAL_DIR}

    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] memcheck libs not supported build type."
                ;;
            debug)
                mkdir -p ${LOCAL_DIR}/install_debug/lib
                mkdir -p ${LOCAL_DIR}/install_debug/gcc8.2.0/lib
                log "[Notice] memcheck libs copy string: copy libasan.a  liblsan.a  libtsan.a  libubsan.a from ${LOCAL_DIR}/../../buildtools/gcc/install_comm/lib64"
                files="libasan.a  liblsan.a  libtsan.a  libubsan.a"
                rm -rf ${LOCAL_DIR}/install_debug/lib/*
                rm -rf ${LOCAL_DIR}/install_debug/gcc8.2.0/lib/*
                for f in $files
                do
                    log "fetching ${LOCAL_DIR}/../../buildtools/gcc/install_comm/lib64/$f"
                    cp ${LOCAL_DIR}/../../buildtools/gcc/install_comm/lib64/$f ${LOCAL_DIR}/install_debug/lib/
                    cp ${LOCAL_DIR}/../../buildtools/gcc/install_comm/lib64/$f ${LOCAL_DIR}/install_debug/gcc8.2.0/lib/
                done
                ;;
            comm)
                die "[Error] memcheck libs not supported build type."
                ;;
            release_llt)
                die "[Error] memcheck libs not supported build type."
                ;;
            debug_llt)
                die "[Error] memcheck libs not supported build type."
                ;;
            llt)
                die "[Error] memcheck libs not supported build type."
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] memcheck libs copy failed."
        fi
        log "[Notice] memcheck libs End copy"
    done
}

#######################################################################
# choose the real files
#######################################################################
function shrink_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm) ;;
            release) ;;

            debug) 
                mkdir -p ${LOCAL_DIR}/install_debug_dist/debug
                cp -rf ${LOCAL_DIR}/install_debug/* ${LOCAL_DIR}/install_debug_dist/debug/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_debug/* ${LOCAL_DIR}/install_debug_dist\" failed."
                fi
                ;;
                
            llt) ;;
            
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] memcheck libs shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm) ;;
            release) ;;

            debug) 
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/*
                cp -rf ${LOCAL_DIR}/install_debug_dist/* ${INSTALL_COMPOENT_PATH_NAME}/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_debug_dist/* ${INSTALL_COMPOENT_PATH_NAME}/\" failed."
                fi
                ;;

            llt) ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] memcheck libs dist using \"${COMPILE_TYPE}\" has been finished!"
    done
}

#######################################################################
# clean component
#######################################################################
function clean_component() {
    cd ${LOCAL_DIR}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR} failed."
    fi
    if [ -d "${SOURCE_CODE_PATH}" ]; then
        rm -rf ${SOURCE_CODE_PATH}
    fi
    rm -rf install_*

    log "[Notice] memcheck libs clean has been finished!"
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
