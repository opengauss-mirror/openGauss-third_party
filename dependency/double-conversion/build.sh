#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# description: the script that make install double-conversion
# date: 2020-05-18

set -e

######################################################################
# Parameter setting
######################################################################
ZIP_FILE_NAME=double-conversion-3.1.1.zip
SOURCE_CODE_PATH=double-conversion-3.1.1

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

#######################################################################
# build and install component
#######################################################################
function build_component() {
    cd ${SCRIPT_PATH}

    if [ $? -ne 0 ]; then
        die "[Error] change dir to ${SCRIPT_PATH} failed."
    fi

    rm -rf ${SCRIPT_PATH}/${SOURCE_CODE_PATH}
    unzip -o ${ZIP_FILE_NAME} > ${LOG_FILE}
    mkdir -p ${SCRIPT_PATH}/${SOURCE_CODE_PATH}/build
    cd ${SCRIPT_PATH}/${SOURCE_CODE_PATH}/build

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] double-conversion Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] double-conversion not supported build type."
                ;;
            debug)
                die "[Error] double-conversion not supported build type."
                ;;
            llt)
                mkdir -p ${SCRIPT_PATH}/install_llt
                cmake -DCMAKE_INSTALL_PREFIX=${SCRIPT_PATH}/install_llt ..
                sed -i 's/CXX_FLAGS =/CXX_FLAGS = -D_GLIBCXX_USE_CXX11_ABI=0 -fPIC/g' CMakeFiles/double-conversion.dir/flags.make
                ;;
            release_llt)
                die "[Error] double-conversion not supported build type."
                ;;
            debug_llt)
                die "[Error] double-conversion not supported build type."
                ;;
            comm)
                mkdir -p ${SCRIPT_PATH}/install_comm
                cmake -DCMAKE_INSTALL_PREFIX=${SCRIPT_PATH}/install_comm ..
                sed -i 's/CXX_FLAGS =/CXX_FLAGS = -D_GLIBCXX_USE_CXX11_ABI=0 -fPIC/g' CMakeFiles/double-conversion.dir/flags.make
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] double-conversion configure failed."
        fi
        log "[Notice] double-conversion End configure"

        log_process "[Notice] double-conversion using \"${COMPILE_TYPE}\" Begin make"
        make -j${MAKE_JOBS} >> ${BUILD_LOG_FILE} 2>&1
        if [ $? -ne 0 ]; then
            die "double-conversion make failed."
        fi
        log_process_done

        log_process "[Notice] double-conversion using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] double-conversion make install failed."
        fi
        log_process_done
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
        log "[Notice] double-conversion shrink using \"${COMPILE_TYPE}\" has been finished!"
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
        log "[Notice] double-conversion dist using \"${COMPILE_TYPE}\" has been finished!"
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

    cd ${SCRIPT_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${SCRIPT_PATH} failed."
    fi
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf ${SOURCE_CODE_PATH}
    rm -rf install_*

    log "[Notice] double-conversion clean has been finished!"
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
