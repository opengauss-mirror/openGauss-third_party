#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install mpc
#  date: 2015-8-20
#  version: 1.0
#  history:
#
# *************************************************************************

######################################################################
# Parameter setting
######################################################################
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
TAR_FILE_NAME=mpc-1.1.0.tar.gz
SOURCE_CODE_PATH=mpc-1.1.0
LOG_FILE=${LOCAL_DIR}/build_mpc.log
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
    echo "[Build mpc] $(date +%y-%m-%d" "%T): $@"
    echo "[Build mpc] $(date +%y-%m-%d" "%T): $@" >> "$LOG_FILE" 2>&1
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
gcc_version=8.2

if [ "${PLAT_FORM_STR}"X = "Failed"X ]; then
    die "[Error] the plat form is not supported!"
fi

if [ "${COMPONENT_NAME}"X = ""X ]; then
    die "[Error] get component name failed!"
fi

if [ "${COMPONENT_TYPE}"X = ""X ]; then
    die "[Error] get component type failed!"
fi

ROOT_DIR="${LOCAL_DIR}/../../.."
INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/${COMPONENT_TYPE}/${PLAT_FORM_STR}/gcc${gcc_version}/${COMPONENT_NAME}"
LIB_PATH="${LOCAL_DIR}/.."

#######################################################################
# build and install component
#######################################################################
function build_component() {
    ##########################################################################
    # the mpc must depend on gmp and mpfr. mpfr must depend on gmp.
    #       config.ini about gmp  and mpfr components default supported comm
    ##########################################################################
    ls -ll ${LIB_PATH}/gmp/install_comm/* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log "gmp has been builded."
    else
        chmod +x ${LIB_PATH}/gmp/build.sh
        ${LIB_PATH}/gmp/build.sh -m build
    fi

    ls -ll ${LIB_PATH}/mpfr/install_comm/* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        log "mpfr has been builded."
    else
        chmod +x ${LIB_PATH}/mpfr/build.sh
        ${LIB_PATH}/mpfr/build.sh -m build
    fi

    cd ${LOCAL_DIR}
    tar -xvf ${TAR_FILE_NAME} >> ${LOG_FILE} 2>&1

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    chmod +x configure
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case ${COMPILE_TYPE} in
            release)
                die "[Error] mpc not supported build type."
                ;;
            debug)
                die "[Error] mpc not supported build type."
                ;;
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm
                log "[Notice] mpc configure string: ./configure --prefix=${LOCAL_DIR}/install_comm --with-gmp=${LIB_PATH}/gmp/install_comm/ --with-mpfr=${LIB_PATH}/mpfr/install_comm/"
                ./configure --prefix=${LOCAL_DIR}/install_comm --with-gmp=${LIB_PATH}/gmp/install_comm/ --with-mpfr=${LIB_PATH}/mpfr/install_comm/ >> ${LOG_FILE} 2>&1
                ;;
            release_llt)
                die "[Error] mpc not supported build type."
                ;;
            debug_llt)
                die "[Error] mpc not supported build type."
                ;;
            llt)
                die "[Error] mpc not supported build type."
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] mpc configure failed."
        fi
        log "[Notice] mpc End configure"

        log "[Notice] mpc using \"${COMPILE_TYPE}\" Begin make"
        make >> ${LOG_FILE} 2>&1
        if [ $? -ne 0 ]; then
            die "mpc make failed."
        fi
        log "[Notice] mpc End make"

        log "[Notice] mpc using \"${COMPILE_TYPE}\" Begin make install"
        make install >> ${LOG_FILE} 2>&1
        if [ $? -ne 0 ]; then
            die "mpc make install failed."
        fi
        log "[Notice] mpc End make install"

        make clean >> ${LOG_FILE} 2>&1
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
                cp -rf ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] mpc shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#	we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case ${COMPILE_TYPE} in
            comm) 
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] mpc dist using \"${COMPILE_TYPE}\" has been finished!"
    done
}

#######################################################################
# clean component
#######################################################################
function clean_component() {
    ls -ll ${LIB_PATH}/gmp/install_comm/* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        ${LIB_PATH}/gmp/build.sh -m clean
    fi

    ls -ll ${LIB_PATH}/mpfr/install_comm/* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        ${LIB_PATH}/mpfr/build.sh -m clean
    fi

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

    log "[Notice] mpc clean has been finished!"
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
