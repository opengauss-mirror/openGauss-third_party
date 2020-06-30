#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# description: the script that make install orc
# date: 2019-12-28
# version: 1.1
# history:
# 2019-5-5 update to ${BUILD_TARGET} 1.7.11 from 1.7.7
# 2019-12-28 fix buildcheck warning

set -e

######################################################################
# Parameter setting
######################################################################
TAR_FILE_NAME=orc-1.5.7.tar.gz
SOURCE_CODE_PATH=orc-1.5.7

######################################################################
# fix func
######################################################################
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

ls ${SCRIPT_PATH}/${CONFIG_FILE_NAME} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    die "[Error] the file ${CONFIG_FILE_NAME} not exist."
fi

# get platform
PLAT_FORM_STR=$(sh ${SCRIPT_PATH}/../../build/get_PlatForm_str.sh)
if [ "${PLAT_FORM_STR}"X = "Failed"X ]; then
    die "[Error] the plat form is not supported!"
fi

# parse config file
COMPONENT_NAME=$(cat ${SCRIPT_PATH}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $1}' | awk -F '@' '{print $2}')
COMPONENT_TYPE=$(cat ${SCRIPT_PATH}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '@' '{print $1}')
COMPLIE_TYPE_LIST=$(cat ${SCRIPT_PATH}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' | awk -F '=' '{print $2}' | sed 's/|/ /g')
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

# print help information
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

#######################################################################
#######################################################################
function init_dependency() {
    item=$1
    cp ${LIB_ROOT_PATH}/${item}/install_comm ${SCRIPT_PATH}/${SOURCE_CODE_PATH}/c++/libs/${item} -rp
    if [ $? -ne 0 ]; then
        die "[Error] ${item} is needed but can't access ${LIB_ROOT_PATH}/${item}/install_comm"
    fi
}

function init_dependencies() {
    init_dependency lz4
    init_dependency protobuf
    init_dependency snappy
    init_dependency zlib
    export LD_LIBRARY_PATH=${SCRIPT_PATH}/${SOURCE_CODE_PATH}/c++/libs/protobuf/lib:$LD_LIBRARY_PATH
}

function build_component() {
    cd ${SCRIPT_PATH}
    rm -rf ${SOURCE_CODE_PATH}

    log_process "[Notice] ${TAR_FILE_NAME} unpackage... "
    tar -xvf ${TAR_FILE_NAME} > ${LOG_FILE}
    log_process_done

    patch_for_build "p0" "huawei_orc-1.5.7.patch" || true

    init_dependencies

    cd ${SCRIPT_PATH}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    mkdir -p build
    rm -rf build/*
    cd build

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] ${BUILD_TARGET} not supported build type."
                ;;
            debug)
                die "[Error] ${BUILD_TARGET} not supported build type."
                ;;
            release_llt)
                die "[Error] ${BUILD_TARGET} not supported build type."
                ;;
            debug_llt)
                die "[Error] ${BUILD_TARGET} not supported build type."
                ;;
            llt)
                die "[Error] ${BUILD_TARGET} not supported build type."
                ;;
            comm)
                log_process "[Notice] ${BUILD_TARGET} using \"${COMPILE_TYPE}\" Begin cmake... "
                cmake .. -DCMAKE_INSTALL_PREFIX=${SCRIPT_PATH}/install_${COMPILE_TYPE} >> ${BUILD_LOG_FILE} 2>&1
                if [ $? -ne 0 ]; then
                    die "${BUILD_TARGET} cmake failed."
                fi
                log_process_done
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        log_process "[Notice] ${BUILD_TARGET} using \"${COMPILE_TYPE}\" Begin make... "
        make -j >> ${BUILD_LOG_FILE} 2>&1
        if [ $? -ne 0 ]; then
            die "${BUILD_TARGET} make failed."
        fi
        #log "[Notice] ${BUILD_TARGET} End make"
        log_process_done

        log_process "[Notice] ${BUILD_TARGET} using \"${COMPILE_TYPE}\" Begin make install... "
        make install >> ${BUILD_LOG_FILE} 2>&1
        cp ${SCRIPT_PATH}/${SOURCE_CODE_PATH}/build/c++/src/orc_proto.pb.h ${SCRIPT_PATH}/install_${COMPILE_TYPE}/include/
        cp ${SCRIPT_PATH}/${SOURCE_CODE_PATH}/build/c++/src/Adaptor.hh ${SCRIPT_PATH}/install_${COMPILE_TYPE}/include/orc/
        cp ${SCRIPT_PATH}/${SOURCE_CODE_PATH}/c++/src/Exceptions.hh ${SCRIPT_PATH}/install_${COMPILE_TYPE}/include/orc/
        if [ $? -ne 0 ]; then
            die "[Error] ${BUILD_TARGET} make install failed."
        fi
        #log "[Notice] ${BUILD_TARGET} using \"${COMPILE_TYPE}\" End make install"
        log_process_done
    done
}

# pick needed files
function shrink_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log_process "[Notice] Begin ${BUILD_TARGET} shrink using \"${COMPILE_TYPE}\"... "
        case "${COMPILE_TYPE}" in
            release) ;;

            comm)
                mkdir -p ${SCRIPT_PATH}/install_${COMPILE_TYPE}_dist
                rm -rf ${SCRIPT_PATH}/install_${COMPILE_TYPE}_dist/*
                cp -r ${SCRIPT_PATH}/install_${COMPILE_TYPE}/* ${SCRIPT_PATH}/install_${COMPILE_TYPE}_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${SCRIPT_PATH}/install_${COMPILE_TYPE}/* ${SCRIPT_PATH}/install_${COMPILE_TYPE}_dist\" failed."
                fi
                ;;
            llt) ;;

            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log_process_done
    done
}

##############################################################################################################
# dist the real files to the matched path
#    we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log_process "[Notice] Begin ${BUILD_TARGET} dist using \"${COMPILE_TYPE}\"... "
        case "${COMPILE_TYPE}" in
            comm | llt)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/${COMPILE_TYPE}/
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/${COMPILE_TYPE}/*
                cp -r ${SCRIPT_PATH}/install_${COMPILE_TYPE}_dist/* ${INSTALL_COMPOENT_PATH_NAME}/${COMPILE_TYPE}
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${SCRIPT_PATH}/install_${COMPILE_TYPE}_dist/* ${INSTALL_COMPOENT_PATH_NAME}/${COMPILE_TYPE}\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log_process_done
    done
}

# clean component
function clean_component() {
    set +e
    log_process "[Notice] Begin ${BUILD_TARGET} clean... "
    cd ${SCRIPT_PATH}
    # make clean:
    if [ -d "${SOURCE_CODE_PATH}/build" ]; then
        cd ${SOURCE_CODE_PATH}/build
        make clean -s > /dev/null 2>&1
    fi

    cd ${SCRIPT_PATH}
    rm -rf ${SOURCE_CODE_PATH}
    rm -rf install_*
    log_process_done

    rm -rf *.log
    set -e
}

function handle() {
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

function main() {
    if [ $# = 0 ]; then
        log "missing option"
        print_help
        exit 1
    fi

    # read command line paramenters
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

    handle
}

#######################################################################
#######################################################################
#######################################################################

main $@
