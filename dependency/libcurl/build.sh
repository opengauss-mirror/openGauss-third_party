#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# description: the script that make install libcurl
# date: 2020-01-04
# version: 7.66.0
# history:
# 2020-01-04 upgrade to curl-7.66.0.tar.gz

set -e

######################################################################
# Parameter setting
######################################################################
TAR_FILE_NAME=curl-7.66.0.tar.gz
SOURCE_CODE_PATH=curl-7.66.0

SCRIPT_PATH=$(
    cd $(dirname $0)
    pwd
)

CONFIG_FILE_NAME=config.ini

# dependencies path
LIB_ROOT_PATH=${SCRIPT_PATH}/..
ROOT_DIR="${SCRIPT_PATH}/../../.."
BUILD_TARGET=$(echo ${SCRIPT_PATH} | awk -F "/" '{print $NF}')

BUILD_LOG_FILE=${SCRIPT_PATH}/build_${BUILD_TARGET}.log
LOG_FILE=${SCRIPT_PATH}/${BUILD_TARGET}.log

BUILD_FAILED=1
FORMART_SIZE=100

#######################################################################
## print help information
#######################################################################
function print_help() {
    echo "Usage: $0 [OPTION]
        -h|--help               show help information
        -m|--build_option       provode type of operation, values of paramenter is build, shrink, dist or clean
    "
}

#  Print log.
log() {
    echo "[Build ${BUILD_TARGET}] $(date +%y-%m-%d' '%T): $@" | tee -a "$LOG_FILE" 2>&1
}

log_process() {
    printf "%-${FORMART_SIZE}s" "[Build ${BUILD_TARGET}] $(date +%y-%m-%d' '%T): $@" | tee -a "$LOG_FILE" 2>&1
}

log_process_done() {
    echo "done" | tee -a "$LOG_FILE" 2>&1
}

die() {
    log "$@"
    echo "$@"
    exit $BUILD_FAILED
}

ls ${SCRIPT_PATH}/${CONFIG_FILE_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    die "[Error] the file ${CONFIG_FILE_NAME} not exist."
fi

COMPLIE_TYPE_LIST=$(cat ${SCRIPT_PATH}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $2}' | sed 's/|/ /g')
COMPONENT_NAME=$(cat ${SCRIPT_PATH}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $1}' | awk -F '@' '{print $2}')
COMPONENT_TYPE=$(cat ${SCRIPT_PATH}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '@' '{print $1}')
PLAT_FORM_STR=$(sh ${SCRIPT_PATH}/../../build/get_PlatForm_str.sh)

if [ "${PLAT_FORM_STR}"X = "Failed"X ]; then
    die "[Error] the plat form is not supported!"
fi

if [ "${COMPONENT_NAME}"X = ""X ]; then
    die "[Error] get component name failed!"
fi

if [ "${COMPONENT_TYPE}"X = ""X ]; then
    die "[Error] get component type failed!"
fi

INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/${COMPONENT_TYPE}/${PLAT_FORM_STR}/${COMPONENT_NAME}"

function patch_for_build() {
    level=$1
    item=$2

    log_process "[Notice] ${item} patching... "
    patch -${level} < ${item} >> ${LOG_FILE} 2>&1
    log_process_done
}

#######################################################################
#######################################################################
function init_dependency() {
    item=${1}

    item_install_comm=${LIB_ROOT_PATH}/${item}/install_comm
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${item_install_comm}/lib

    if [ $? -ne 0 ]; then
        die "[Error] ${item} is needed but can't access ${LIB_ROOT_PATH}/${item}/install_comm"
    fi
}

function init_dependencies() {
    init_dependency openssl
    init_dependency zlib
    init_dependency kerberos
    export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${LIB_ROOT_PATH}/kerberos/install_comm/include
}

#######################################################################
# build and install component
#######################################################################
function build_component() {
    cd ${SCRIPT_PATH}

    if [ $? -ne 0 ]; then
        die "[Error] change dir to ${SCRIPT_PATH} failed."
    fi

    init_dependencies
    tar -xvf ${TAR_FILE_NAME} > ${LOG_FILE}

    patch_for_build p0 huawei_curl.patch
    cd ${SCRIPT_PATH}/${SOURCE_CODE_PATH}

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] libcurl Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] libcurl not supported build type."
                ;;
            debug)
                die "[Error] libcurl not supported build type."
                ;;
            llt)
                mkdir -p ${SCRIPT_PATH}/install_llt
                ./configure --prefix=${SCRIPT_PATH}/install_llt --with-ssl=${LIB_ROOT_PATH}/openssl/install_comm --without-libssh2 CFLAGS='-fstack-protector-strong -Wl,-z,relro,-z,now' --with-zlib=${LIB_ROOT_PATH}/zlib/install_comm --with-gssapi_krb5_gauss-includes=${LIB_ROOT_PATH}/openssl/install_comm/include --with-gssapi_krb5_gauss-libs=${LIB_ROOT_PATH}/openssl/install_comm/lib >> $LOG_FILE 2>&1
                ;;
            release_llt)
                die "[Error] libcurl not supported build type."
                ;;
            debug_llt)
                die "[Error] libcurl not supported build type."
                ;;
            comm)
                mkdir -p ${SCRIPT_PATH}/install_comm
                ./configure --prefix=${SCRIPT_PATH}/install_comm --with-ssl=${LIB_ROOT_PATH}/openssl/install_comm --without-libssh2 CFLAGS='-fstack-protector-strong -Wl,-z,relro,-z,now' --with-zlib=${LIB_ROOT_PATH}/zlib/install_comm --with-gssapi_krb5_gauss-includes=${LIB_ROOT_PATH}/openssl/install_comm/include --with-gssapi_krb5_gauss-libs=${LIB_ROOT_PATH}/openssl/install_comm/lib >> $LOG_FILE 2>&1
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] libcurl configure failed."
        fi
        log "[Notice] libcurl End configure"

        log_process "[Notice] libcurl using \"${COMPILE_TYPE}\" Begin make"
        make -j >> ${BUILD_LOG_FILE} 2>&1
        if [ $? -ne 0 ]; then
            die "libcurl make failed."
        fi
        log_process_done

        log_process "[Notice] libcurl using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] libcurl make install failed."
        fi
        log_process_done

        make clean
        log "[Notice] libcurl build using \"${COMPILE_TYPE}\" has been finished"
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
                mkdir -p ${SCRIPT_PATH}/install_comm_dist
                cp -r ${SCRIPT_PATH}/install_comm/* ${SCRIPT_PATH}/install_comm_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${SCRIPT_PATH}/install_comm/* ${SCRIPT_PATH}/install_comm_dist\" failed."
                fi
                ;;
            llt)
                mkdir -p ${SCRIPT_PATH}/install_llt_dist
                cp -r ${SCRIPT_PATH}/install_llt/* ${SCRIPT_PATH}/install_llt_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${SCRIPT_PATH}/install_llt/* ${SCRIPT_PATH}/install_llt_dist\" failed."
                fi
                ;;
            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] libcurl shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#    we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/*
                cp -rf ${SCRIPT_PATH}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${SCRIPT_PATH}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi
                ;;
            llt)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/llt/*
                cp -rf ${SCRIPT_PATH}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${SCRIPT_PATH}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] libcurl dist using \"${COMPILE_TYPE}\" has been finished!"
    done
}

#######################################################################
# clean component
#######################################################################
function clean_component() {
    cd ${SCRIPT_PATH}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${SCRIPT_PATH}/${SOURCE_CODE_PATH} failed."
    fi

    make clean

    cd ${SCRIPT_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${SCRIPT_PATH} failed."
    fi
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf ${SOURCE_CODE_PATH}
    rm -rf install_*

    log "[Notice] libcurl clean has been finished!"
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
