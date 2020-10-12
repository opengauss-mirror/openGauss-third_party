#!/bin/bash
#  Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
#  description: the script that make install lz4
#  date: 2019-12-28
#  version: 1.11
#  history:
#    2019-5-5 update to lz4 1.8.3 from 1.7.5
#    2019-12-12 update to lz4 1.9.2 from 1.8.3
#    2019-12-28 change formatting and add copyright notice

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

TAR_FILE_NAME=lz4-1.9.2.tar.gz
SOURCE_CODE_PATH=lz4-1.9.2

LOG_FILE=${LOCAL_DIR}/build_lz4.log
BUILD_FAILED=1
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

#######################################################################
#  Print log.
#######################################################################
log() {
    echo "[Build lz4] "$(date +%y-%m-%d" "%T)": $@"
    echo "[Build lz4] "$(date +%y-%m-%d" "%T)": $@" >> "$LOG_FILE" 2>&1
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
# build and install component
#######################################################################
function build_component() {
    cd ${LOCAL_DIR}
    tar -xvf ${TAR_FILE_NAME}

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    # copy and apply patch
    log "[Notice] begin apply patch to lz4 "
    cd lib/
    cp ../../huawei_lz4.patch ./
    patch -Np0 < huawei_lz4.patch
    if [ $? -ne 0 ]; then
        die "[Error] apply patch failed."
    fi
    log "[Notice] finish apply patch to lz4 "

    # chmod +x configure
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] lz4 not supported build type."
                ;;
            debug)
                die "[Error] lz4 not supported build type."
                ;;
            release_llt)
                die "[Error] lz4 not supported build type."
                ;;
            debug_llt)
                die "[Error] lz4 not supported build type."
                ;;
            comm | llt)
                mkdir -p ${LOCAL_DIR}/install_${COMPILE_TYPE}

                log "[Notice] lz4 using \"${COMPILE_TYPE}\" Begin make"

                if [ "${COMPILE_TYPE}"X = "comm"X ]; then
                    sed -i '53a CFLAGS += -fPIC -Wl,-z,now -fstack-protector-all' Makefile
                    make -j${MAKE_JOBS}
                else
                    make -j${MAKE_JOBS}
                fi
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "lz4 make failed."
        fi
        log "[Notice] lz4 End make"

        log "[Notice] lz4 using \"${COMPILE_TYPE}\" Begin make install"
        make install prefix=${LOCAL_DIR}/install_${COMPILE_TYPE}
        if [ $? -ne 0 ]; then
            die "[Error] lz4 make install failed."
        fi
        log "[Notice] lz4 using \"${COMPILE_TYPE}\" End make install"
        make clean -s
        log "[Notice] lz4 build using \"${COMPILE_TYPE}\" has been finished"
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
                cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist\" failed."
                fi
                ;;
            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] lz4 shrink using \"${COMPILE_TYPE}\" has been finished!"
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
                [ -n "${INSTALL_COMPOENT_PATH_NAME}"/comm/ ] && rm -rf "${INSTALL_COMPOENT_PATH_NAME}"/comm/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi
                ;;
            llt)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt
                [ -n "${INSTALL_COMPOENT_PATH_NAME}"/llt/ ] && rm -rf "${INSTALL_COMPOENT_PATH_NAME}"/llt/*
                cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] lz4 dist using \"${COMPILE_TYPE}\" has been finished!"
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
        cd ${SOURCE_CODE_PATH}
        make clean
        cd ${LOCAL_DIR}
        rm -rf ${SOURCE_CODE_PATH}
    fi
    rm -rf install_*
    rm -rf *.log

    log "[Notice] libedit clean has been finished!"
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
            clean_component
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
