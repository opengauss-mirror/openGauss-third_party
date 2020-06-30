#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# description: the script that make install numactl
# date: 2020-01-04
# version: 1.39.2

######################################################################
# Parameter setting
######################################################################
set -e

LOCAL_PATH=${0}
FIRST_CHAR=$(expr substr "$LOCAL_PATH" 1 1)
if [ $FIRST_CHAR = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi

LOCAL_DIR=$(dirname "${LOCAL_PATH}")
CONFIG_FILE_NAME=config.ini
BUILD_OPTION=release
TAR_FILE_NAME=numactl-2.0.13.tar.gz
SOURCE_CODE_PATH=numactl-2.0.13
LOG_FILE=${LOCAL_DIR}/build_numactl.log
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
        -m|--build_option       provode type of operation, values of paramenter is build, shrink, dist or clean
    "
}

#######################################################################
#  Print log.
#######################################################################
log() {
    echo "[Build numactl] $(date +%y-%m-%d" "%T): $@"
    echo "[Build numactl] $(date +%y-%m-%d" "%T): $@" >> "$LOG_FILE" 2>&1
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
    tar -xvf ${TAR_FILE_NAME}

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    chmod +x configure
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] numactl Begin configure..."
        case ${COMPILE_TYPE} in
            release)
                die "[Error] numactl not supported build type."
                ;;
            debug)
                die "[Error] numactl not supported build type."
                ;;
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm
                log "[Notice] numactl configure string: ./configure --prefix=${LOCAL_DIR}/install_comm"
                ./configure CFLAGS='-fstack-protector-all -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fPIC' --prefix=${LOCAL_DIR}/install_comm
                ;;
            release_llt)
                die "[Error] numactl not supported build type."
                ;;
            debug_llt)
                die "[Error] numactl not supported build type."
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt
                log "[Notice] numactl configure string: ./configure --prefix=${LOCAL_DIR}/install_llt"
                ./configure CFLAGS='-fstack-protector-all -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fPIC' --prefix=${LOCAL_DIR}/install_llt
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] numactl configure failed."
        fi
        log "[Notice] numactl End configure"

        log "[Notice] numactl using \"${COMPILE_TYPE}\" Begin make"
        make -j4
        if [ $? -ne 0 ]; then
            die "numactl make failed."
        fi
        log "[Notice] numactl End make"

        log "[Notice] numactl using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] numactl make install failed."
        fi
        log "[Notice] numactl using \"${COMPILE_TYPE}\" End make install"

        make clean
        log "[Notice] numactl build using \"${COMPILE_TYPE}\" has been finished"
    done
}

#######################################################################
# choose the real files
#######################################################################
function shrink_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case ${COMPILE_TYPE} in
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install_comm/include ${LOCAL_DIR}/install_comm_dist
                mkdir -p ${LOCAL_DIR}/install_comm_dist/lib
                cp -r ${LOCAL_DIR}/install_comm/lib/*so* ${LOCAL_DIR}/install_comm_dist/lib
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist
                cp -r ${LOCAL_DIR}/install_llt/include ${LOCAL_DIR}/install_llt_dist
                mkdir -p ${LOCAL_DIR}/install_llt_dist/lib
                cp -r ${LOCAL_DIR}/install_llt/lib/*so* ${LOCAL_DIR}/install_llt_dist/lib
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist\" failed."
                fi
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] numactl shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#    we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case ${COMPILE_TYPE} in
            comm)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/llt/*
                cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt\" failed."
                fi
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] numactl dist using \"${COMPILE_TYPE}\" has been finished!"
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

    make clean

    cd ${LOCAL_DIR}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR} failed."
    fi
    rm -rf ${SOURCE_CODE_PATH}
    rm -rf install_*

    log "[Notice] numactl clean has been finished!"
}
#######################################################################
#######################################################################
#######################################################################
# main
#######################################################################
#######################################################################
#######################################################################
function main() {
    case ${BUILD_OPTION} in
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
    case $1 in
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
