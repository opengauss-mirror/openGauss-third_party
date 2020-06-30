#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2020. All rights reserved.
#  description: the script that make install libtinfo
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
TAR_FILE_NAME=ncurses-6.2.tar.gz
SOURCE_CODE_PATH=ncurses-6.2
LOG_FILE=${LOCAL_DIR}/build_libncurses-6.2.log
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
    echo "[Build libtinfo] $(date +%y-%m-%d" "%T): $@"
    echo "[Build libtinfo] $(date +%y-%m-%d" "%T): $@" >> "$LOG_FILE" 2>&1
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
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] libtinfo not supported build type."
                ;;
            debug)
                die "[Error] libtinfo not supported build type."
                ;;
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm
                log "[Notice] libtinfo configure string: ./configure --prefix=${LOCAL_DIR}/install_comm --with-termlib"
                ./configure CFLAGS='-fPIC' --prefix=${LOCAL_DIR}/install_comm --with-termlib
                ;;
            release_llt)
                die "[Error] libtinfo not supported build type."
                ;;
            debug_llt)
                die "[Error] libtinfo not supported build type."
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt
                log "[Notice] libtinfo configure string: ./configure  CFLAGS='-fPIC' --prefix=${LOCAL_DIR}/install_llt --with-termlib"
                ./configure CFLAGS='-fPIC' --prefix=${LOCAL_DIR}/install_llt --with-termlib
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] libtinfo configure failed."
        fi
        log "[Notice] libtinfo End configure"

        log "[Notice] libtinfo using \"${COMPILE_TYPE}\" Begin make"
        make -j4
        if [ $? -ne 0 ]; then
            die "libtinfo make failed."
        fi
        log "[Notice] libtinfo End make"

        log "[Notice] libtinfo using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "libtinfo make install failed."
        fi
        log "[Notice] libtinfo End make install"

        make distclean
    done
}

#######################################################################
# choose the real files
#######################################################################
function shrink_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm_dist/lib
                cp ${LOCAL_DIR}/install_comm/lib/libtinfo.a ${LOCAL_DIR}/install_comm_dist/lib
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist/lib
                cp ${LOCAL_DIR}/install_llt/lib/libtinfo.a ${LOCAL_DIR}/install_llt_dist/lib
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist\" failed."
                fi
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] libtinfo shrink using \"${COMPILE_TYPE}\" has been finished!"
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
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm/
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/*
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm
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
                mkdir ${INSTALL_COMPOENT_PATH_NAME}/llt -p
                cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt\" failed."
                fi
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] libtinfo dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] libtinfo clean has been finished!"
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
