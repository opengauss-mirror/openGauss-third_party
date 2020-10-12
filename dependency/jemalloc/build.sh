#!/bin/bash
# ***********************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# the script that make install jemalloc
# version: 1.0.0
# change log:
# ***********************************************************************
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
TAR_FILE_NAME=jemalloc-5.2.1.zip
SOURCE_CODE_PATH=jemalloc-5.2.1
LOG_FILE=${LOCAL_DIR}/build_jemalloc.log
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
    echo "[Build jemalloc] $(date +%y-%m-%d\" \"%T): $@"
    echo "[Build jemalloc] $(date +%y-%m-%d\" \"%T): $@" >> "$LOG_FILE" 2>&1
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
#COMPONENT_NAME=`cat ${LOCAL_DIR}/${CONFIG_FILE_NAME} | grep -v '#' | grep -v '^$' |awk -F '=' '{print $1}'| awk -F '@' '{print $2}'`
COMPONENT_NAME=jemalloc
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
    unzip -o ${TAR_FILE_NAME}

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    sh autogen.sh
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    chmod +x configure
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] jemalloc Begin configure..."
        case "${COMPILE_TYPE}" in
            comm)
                die "[Error] jemalloc not supported build type."
                ;;
            llt)
                die "[Error] jemalloc not supported build type."
                ;;
            release)
                mkdir -p ${LOCAL_DIR}/install_release
                log "[Notice] jemalloc configure string: ./configure --prefix=${LOCAL_DIR}/install_release"
                #--with-lg-page=16  euleros need this.
                ./configure CFLAGS=-fPIC CXXFLAGS=-fPIC --with-malloc-conf="background_thread:true,dirty_decay_ms:0,muzzy_decay_ms:0,lg_extent_max_active_fit:2" --prefix=${LOCAL_DIR}/install_release
                ;;
            release_llt)
                die "[Error] jemalloc not supported build type."
                ;;
            debug_llt)
                die "[Error] jemalloc not supported build type."
                ;;
            debug)
                mkdir -p ${LOCAL_DIR}/install_debug
                log "[Notice] jemalloc configure string: ./configure --enable-debug --enable-prof --prefix=${LOCAL_DIR}/install_debug"
                #--with-lg-page=16  euleros need this.
                ./configure CFLAGS=-fPIC CXXFLAGS=-fPIC --with-malloc-conf="background_thread:true,dirty_decay_ms:0,muzzy_decay_ms:0,lg_extent_max_active_fit:2" --enable-debug --enable-prof --prefix=${LOCAL_DIR}/install_debug
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] jemalloc configure failed."
        fi
        log "[Notice] jemalloc End configure"

        log "[Notice] jemalloc using \"${COMPILE_TYPE}\" Begin make"
        make -j4
        if [ $? -ne 0 ]; then
            die "jemalloc make failed."
        fi
        log "[Notice] jemalloc End make"

        log "[Notice] jemalloc using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] jemalloc make install failed."
        fi
        log "[Notice] jemalloc using \"${COMPILE_TYPE}\" End make install"

        make clean
        log "[Notice] jemalloc build using \"${COMPILE_TYPE}\" has been finished"
    done
}

#######################################################################
# choose the real files
#######################################################################
function shrink_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            release)
                mkdir ${LOCAL_DIR}/install_release_dist
                cp -r ${LOCAL_DIR}/install_release/* ${LOCAL_DIR}/install_release_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_release/* ${LOCAL_DIR}/install_release_dist\" failed."
                fi
                rm -f ${LOCAL_DIR}/install_release_dist/lib/libjemalloc.so*
                rm -f ${LOCAL_DIR}/install_release_dist/lib/libjemalloc_pic.a

                mkdir ${LOCAL_DIR}/install_release_llt_dist
                cp -r ${LOCAL_DIR}/install_release/* ${LOCAL_DIR}/install_release_llt_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_release/* ${LOCAL_DIR}/install_release_llt_dist\" failed."
                fi
                rm -f ${LOCAL_DIR}/install_release_llt_dist/lib/libjemalloc.so*
                rm -f ${LOCAL_DIR}/install_release_llt_dist/lib/libjemalloc.a
                ;;
            debug)
                mkdir ${LOCAL_DIR}/install_debug_dist
                cp -r ${LOCAL_DIR}/install_debug/* ${LOCAL_DIR}/install_debug_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_debug/* ${LOCAL_DIR}/install_debug_dist\" failed."
                fi
                rm -f ${LOCAL_DIR}/install_debug_dist/lib/libjemalloc.so*
                rm -f ${LOCAL_DIR}/install_debug_dist/lib/libjemalloc_pic.a

                mkdir ${LOCAL_DIR}/install_debug_llt_dist
                cp -r ${LOCAL_DIR}/install_debug/* ${LOCAL_DIR}/install_debug_llt_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_debug/* ${LOCAL_DIR}/install_debug_llt_dist\" failed."
                fi
                rm -f ${LOCAL_DIR}/install_debug_llt_dist/lib/libjemalloc.so*
                rm -f ${LOCAL_DIR}/install_debug_llt_dist/lib/libjemalloc.a
                ;;
            comm) ;;

            llt) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] jemalloc shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            release)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/release/
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/release/*
                cp -r ${LOCAL_DIR}/install_release_dist/* ${INSTALL_COMPOENT_PATH_NAME}/release
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_release_dist/* ${INSTALL_COMPOENT_PATH_NAME}/release\" failed."
                fi

                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/release_llt
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/release_llt/*
                cp -r ${LOCAL_DIR}/install_release_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/release_llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_release_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/release_llt\" failed."
                fi
                ;;
            comm) ;;

            llt) ;;

            debug)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/debug
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/debug/*
                cp -r ${LOCAL_DIR}/install_debug_dist/* ${INSTALL_COMPOENT_PATH_NAME}/debug
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_debug_dist/* ${INSTALL_COMPOENT_PATH_NAME}/debug\" failed."
                fi

                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/debug_llt
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/debug_llt/*
                cp -r ${LOCAL_DIR}/install_debug_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/debug_llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_debug_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/debug_llt\" failed."
                fi
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] jemalloc dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] jemalloc clean has been finished!"
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
            clean_component
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
