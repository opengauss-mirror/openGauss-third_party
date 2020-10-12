#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# description: the script that make install boost
# date: 2019-12-27
# version: 1.71.0
# history: fix buildcheck warning

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

TAR_FILE_NAME=boost_1_71_0.tar.gz
SOURCE_CODE_PATH=boost_1_71_0

LOG_FILE=${LOCAL_DIR}/build_boost.log
BUILD_FAILED=1

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
    echo "[Build boost] $(date +%y-%m-%d' '%T): $@"
    echo "[Build boost] $(date +%y-%m-%d' '%T): $@" >> "$LOG_FILE" 2>&1
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

    chmod +x bootstrap.sh
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] boost Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] boost not supported build type."
                ;;
            debug)
                die "[Error] boost not supported build type."
                ;;
            release_llt)
                die "[Error] boost not supported build type."
                ;;
            debug_llt)
                die "[Error] boost not supported build type."
                ;;
            comm)
                python_version=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
                python -c "import sys;exit(1) if sys.version_info >= (3,0) and sys.version_info < (3,8) else exit(0)"
                if [ $? -eq 1 ]; then
                    log "[Notice] python version is between 3.0 and < 3.8, change python.jam to find python 3.x include directory."
                    sed -i 's#includes ?= $(prefix)/include/python$(version) ;#includes ?= $(prefix)/include/python$(version)m ;#' ${LOCAL_DIR}/${SOURCE_CODE_PATH}/tools/build/src/tools/python.jam
                fi
                mkdir -p ${LOCAL_DIR}/install_${COMPILE_TYPE}
                log "[Notice] boost configure string: ./bootstrap.sh --prefix=${LOCAL_DIR}/install_${COMPILE_TYPE}"
                ./bootstrap.sh --prefix=${LOCAL_DIR}/install_${COMPILE_TYPE}
                ./tools/build/src/engine/bjam cflags='-fPIC -D_GLIBCXX_USE_CXX11_ABI=0' cxxflags='-fPIC -D_GLIBCXX_USE_CXX11_ABI=0'
                if [ $? -ne 0 ]; then
                    die "[Error] boost configure failed."
                fi
                log "[Notice] boost End configure"

                if [ "${COMPILE_TYPE}"X = "comm"X ]; then
                    log "[Notice] boost using \"${COMPILE_TYPE}\" Begin make"
                    ./b2
                    log "[Notice] boost End make"
                    log "[Notice] boost using \"${COMPILE_TYPE}\" Begin make install"
                    ./b2 install
                    log "[Notice] boost using \"${COMPILE_TYPE}\" End make install"
                else
                    log "[Notice] boost using \"${COMPILE_TYPE}\" Start pic build"
                    chmod +x ${LOCAL_DIR}/pic_build.sh
                    cd ${LOCAL_DIR}
                    sh pic_build.sh
                    if [ $? -ne 0 ]; then
                        die "[Error] boost pic build failed."
                    fi
                    log "[Notice] boost using \"${COMPILE_TYPE}\" End pic build"
                fi
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
                mkdir -p ${LOCAL_DIR}/install_comm_dist/lib
                cp -r ${LOCAL_DIR}/install_comm/lib/libboost_atomic.a ${LOCAL_DIR}/install_comm_dist/lib/
                cp -r ${LOCAL_DIR}/install_comm/lib/libboost_chrono.a ${LOCAL_DIR}/install_comm_dist/lib/
                cp -r ${LOCAL_DIR}/install_comm/lib/libboost_system.a ${LOCAL_DIR}/install_comm_dist/lib/
                cp -r ${LOCAL_DIR}/install_comm/lib/libboost_thread.a ${LOCAL_DIR}/install_comm_dist/lib/
                cp -rf ${LOCAL_DIR}/install_comm/include ${LOCAL_DIR}/install_comm_dist/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                #rm -f ${LOCAL_DIR}/install_comm_dist/lib/*so*
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist
                mkdir -p ${LOCAL_DIR}/install_llt_dist/lib
                mkdir -p ${LOCAL_DIR}/install_llt_dist/include
                cp ${LOCAL_DIR}/${SOURCE_CODE_PATH}/stage/lib/* ${LOCAL_DIR}/install_llt_dist/lib/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp ${LOCAL_DIR}/${SOURCE_CODE_PATH}/stage/lib/* ${LOCAL_DIR}/install_llt_dist/lib\" failed."
                fi

                cp -r ${LOCAL_DIR}/${SOURCE_CODE_PATH}/boost ${LOCAL_DIR}/install_llt_dist/include/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/${SOURCE_CODE_PATH}/boost ${LOCAL_DIR}/install_llt_dist/include/\" failed."
                fi

                mv ${LOCAL_DIR}/install_llt_dist/lib/libboost_chrono.a ${LOCAL_DIR}/install_llt_dist/lib/libboost_chrono_pic.a
                mv ${LOCAL_DIR}/install_llt_dist/lib/libboost_system.a ${LOCAL_DIR}/install_llt_dist/lib/libboost_system_pic.a
                mv ${LOCAL_DIR}/install_llt_dist/lib/libboost_thread.a ${LOCAL_DIR}/install_llt_dist/lib/libboost_thread_pic.a

                ;;
            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] boost shrink using \"${COMPILE_TYPE}\" has been finished!"
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
                cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi
                ;;
            llt)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/llt/*
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
        log "[Notice] boost dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] boost clean has been finished!"
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
