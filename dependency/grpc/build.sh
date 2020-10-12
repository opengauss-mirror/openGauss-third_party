#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# description: the script that make install grpc
# date: 2020-05-18

set -e

######################################################################
# Parameter setting
######################################################################
TAR_FILE_NAME=grpc-1.22.0.tar.gz
SOURCE_CODE_PATH=grpc-1.22.0

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
LOGIC_CPU_NUMBER=$(cat /proc/cpuinfo | grep processor | wc -l)
MAKE_JOBS=$(($LOGIC_CPU_NUMBER * 2))

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
    patch -N -${level} < ${item} >> ${LOG_FILE} 2>&1
    log_process_done
}

#######################################################################
#######################################################################
function init_dependency() {
    item=${1}

    item_install_comm=${LIB_ROOT_PATH}/${item}/install_comm

    mkdir -p ${SCRIPT_PATH}/pkgconfig
    cp -rp ${item_install_comm}/lib/pkgconfig/*.pc ${SCRIPT_PATH}/pkgconfig

    if [ $? -ne 0 ]; then
        die "[Error] ${item} is needed but can't access ${LIB_ROOT_PATH}/${item}/install_comm"
    fi
}

function init_dependencies() {
    init_dependency openssl
    init_dependency protobuf
    init_dependency c-ares
    init_dependency zlib
    export PATH=${LIB_ROOT_PATH}/protobuf/install_comm/bin:$PATH
    export LD_LIBRARY_PATH=${LIB_ROOT_PATH}/c-ares/install_comm/lib:$LD_LIBRARY_PATH
    export PKG_CONFIG_PATH=${SCRIPT_PATH}/pkgconfig
}

#######################################################################
# build and install component
#######################################################################
function build_component() {
    cd ${SCRIPT_PATH}

    if [ $? -ne 0 ]; then
        die "[Error] change dir to ${SCRIPT_PATH} failed."
    fi

    rm -rf ${SCRIPT_PATH}/${SOURCE_CODE_PATH} ${SCRIPT_PATH}/pkgconfig
    init_dependencies
    tar -xvf ${TAR_FILE_NAME} > ${LOG_FILE}
    cd ${SCRIPT_PATH}/${SOURCE_CODE_PATH}
    patch_for_build "p1" "../huawei_grpc-1.22.0.patch"
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] grpc Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] grpc not supported build type."
                ;;
            debug)
                die "[Error] grpc not supported build type."
                ;;
            llt)
                mkdir -p ${SCRIPT_PATH}/install_llt
                sed -i '862c LIBS_PROTOBUF = ../../protobuf/install_comm/lib/libprotobuf.a' Makefile
                sed -i '863c LIBS_PROTOC = ../../protobuf/install_comm/lib/libprotoc.a ../../protobuf/install_comm/lib/libprotobuf.a' Makefile
                sed -i '865c HOST_LDLIBS_PROTOC += $(LIBS_PROTOC)' Makefile
                sed -i '868c LDLIBS_PROTOBUF += $(shell $(PKG_CONFIG) --libs-only-l ../../protobuf/install_comm/lib/libprotobuf.a)' Makefile
                sed -i '870c LDLIBS_PROTOBUF += $(LIBS_PROTOBUF)' Makefile
                ;;
            release_llt)
                die "[Error] grpc not supported build type."
                ;;
            debug_llt)
                die "[Error] grpc not supported build type."
                ;;
            comm)
                mkdir -p ${SCRIPT_PATH}/install_comm
                sed -i '862c LIBS_PROTOBUF = ../../protobuf/install_comm/lib/libprotobuf.a' Makefile
                sed -i '863c LIBS_PROTOC = ../../protobuf/install_comm/lib/libprotoc.a ../../protobuf/install_comm/lib/libprotobuf.a' Makefile
                sed -i '865c HOST_LDLIBS_PROTOC += $(LIBS_PROTOC)' Makefile
                sed -i '868c LDLIBS_PROTOBUF += $(shell $(PKG_CONFIG) --libs-only-l ../../protobuf/install_comm/lib/libprotobuf.a)' Makefile
                sed -i '870c LDLIBS_PROTOBUF += $(LIBS_PROTOBUF)' Makefile
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] grpc configure failed."
        fi
        log "[Notice] grpc End configure"

        log_process "[Notice] grpc using \"${COMPILE_TYPE}\" Begin make"
        make -j${MAKE_JOBS} >> ${BUILD_LOG_FILE} 2>&1
        if [ $? -ne 0 ]; then
            die "grpc make failed."
        fi
        log_process_done

        log_process "[Notice] grpc using \"${COMPILE_TYPE}\" Begin make install"
        make_install ${COMPILE_TYPE}
        if [ $? -ne 0 ]; then
            die "[Error] grpc make install failed."
        fi
        log_process_done

        make clean
        log "[Notice] grpc build using \"${COMPILE_TYPE}\" has been finished"
    done
}

make_install() {
    COMPILE_TYPE=${1}
    mkdir -p ${SCRIPT_PATH}/install_${COMPILE_TYPE}/include
    mkdir -p ${SCRIPT_PATH}/install_${COMPILE_TYPE}/lib
    cp -r include/* ${SCRIPT_PATH}/install_${COMPILE_TYPE}/include/
    cp -r libs/opt/lib* ${SCRIPT_PATH}/install_${COMPILE_TYPE}/lib/
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
        log "[Notice] grpc shrink using \"${COMPILE_TYPE}\" has been finished!"
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
        log "[Notice] grpc dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] grpc clean has been finished!"
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
