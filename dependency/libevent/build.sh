#!/bin/bash
#  Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
#  description: the script that make install libevent
#  date: 2019-12-28
#  version: 1.01
#  history:
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
TAR_FILE_NAME=libevent-2.1.11-stable.tar.gz
PATCH_FILE_NAME=huawei_libevent-2.1.11-stable_evutil_c.patch
SOURCE_CODE_PATH=libevent-2.1.11-stable
LOG_FILE=${LOCAL_DIR}/build_event.log
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
    echo "[Build libevent] "$(date +%y-%m-%d" "%T)": $@"
    echo "[Build libevent] "$(date +%y-%m-%d" "%T)": $@" >> "$LOG_FILE" 2>&1
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
LIB_PATH="${LOCAL_DIR}/../"
SSL_LIB=${LIB_PATH}/openssl/install_comm/lib
SSL_INCLUDE=${LIB_PATH}/openssl/install_comm/include
INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/${COMPONENT_TYPE}/${PLAT_FORM_STR}/${COMPONENT_NAME}"

#######################################################################
# build and install component
#######################################################################
function build_component() {
    cd ${LOCAL_DIR}
    tar -xvf ${TAR_FILE_NAME}
    patch -Np0 < ${PATCH_FILE_NAME}

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    chmod +x configure
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] event Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] event not supported build type."
                ;;
            debug)
                die "[Error] event not supported build type."
                ;;
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm
                log "[Notice] event configure string: ./configure CFLAGS='-O2 -g3' --enable-static=yes --enable-shared=no --with-pic=false CFLAGS='-fPIE' CPPFLAGS=-I${SSL_INCLUDE} LDFLAGS=-L${SSL_LIB} --prefix=${LOCAL_DIR}/install_comm"
                ./configure CFLAGS='-O2 -g3' --enable-static=yes --enable-shared=no --with-pic=false CFLAGS='-fPIE' CPPFLAGS=-I${SSL_INCLUDE} LDFLAGS=-L${SSL_LIB} --prefix=${LOCAL_DIR}/install_comm
                ;;
            release_llt)
                die "[Error] event not supported build type."
                ;;
            debug_llt)
                die "[Error] event not supported build type."
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt
                log "[Notice] event configure string: ./configure CFLAGS='-O2 -g3' --enable-static=yes --enable-shared=no --with-pic=false CFLAGS='-fPIE' CPPFLAGS=-I${SSL_INCLUDE} LDFLAGS=-L${SSL_LIB} --prefix=${LOCAL_DIR}/install_llt"
                ./configure CFLAGS='-O2 -g3' --enable-static=yes --enable-shared=no --with-pic=false CFLAGS='-fPIE' CPPFLAGS=-I${SSL_INCLUDE} LDFLAGS=-L${SSL_LIB} --prefix=${LOCAL_DIR}/install_llt
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] event configure failed."
        fi
        log "[Notice] event End configure"

        log "[Notice] event using \"${COMPILE_TYPE}\" Begin make"
        make -j4
        if [ $? -ne 0 ]; then
            die "event make failed."
        fi
        log "[Notice] event End make"

        log "[Notice] event using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] event make install failed."
        fi
        log "[Notice] event using \"${COMPILE_TYPE}\" End make install"

        make clean
        log "[Notice] event build using \"${COMPILE_TYPE}\" has been finished"
    done
}

#######################################################################
# choose the real files
#######################################################################
function shrink_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist
                cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist\" failed."
                fi
                mv ${LOCAL_DIR}/install_llt_dist/lib/libevent.a ${LOCAL_DIR}/install_llt_dist/lib/libevent_pic.a
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] event shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm
                [ -n "${INSTALL_COMPOENT_PATH_NAME}"/comm/ ] && rm -rf "${INSTALL_COMPOENT_PATH_NAME}"/comm/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/* "${INSTALL_COMPOENT_PATH_NAME}"/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* "${INSTALL_COMPOENT_PATH_NAME}"/comm\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt
                [ -n "${INSTALL_COMPOENT_PATH_NAME}"/llt/ ] && rm -rf "${INSTALL_COMPOENT_PATH_NAME}"/llt/*
                cp -rf ${LOCAL_DIR}/install_llt_dist/* "${INSTALL_COMPOENT_PATH_NAME}"/llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_llt_dist/* "${INSTALL_COMPOENT_PATH_NAME}"/llt\" failed."
                fi
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] event dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] event clean has been finished!"
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
            #clean_component
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
