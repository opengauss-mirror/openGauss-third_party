#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install thrift
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
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

TAR_FILE_NAME=thrift-0.13.0.tar.gz
SOURCE_CODE_PATH=thrift-0.13.0
LOG_FILE=${LOCAL_DIR}/build_thrift.log
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
    echo "[Build thrift] $(date +%y-%m-%d' '%T): $@"
    echo "[Build thrift] $(date +%y-%m-%d' '%T): $@" >> "$LOG_FILE" 2>&1
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

ROOT_DIR="${LOCAL_DIR}/../../../"
INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/${COMPONENT_TYPE}/${PLAT_FORM_STR}/${COMPONENT_NAME}"

if [ "${PLAT_FORM_STR}"X = "Failed"X ]; then
    die "[Error] the plat form is not supported!"
fi

if [ "${COMPONENT_NAME}"X = ""X ]; then
    die "[Error] get component name failed!"
fi

if [ "${COMPONENT_TYPE}"X = ""X ]; then
    die "[Error] get component type failed!"
fi

##############################################################################################################
# dist the real files to the matched path
#we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm)
                log "[Notice] INSTALL_COMPOENT_PATH_NAME: \"${INSTALL_COMPOENT_PATH_NAME}\" "
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/include/*
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/lib/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/include ${INSTALL_COMPOENT_PATH_NAME}/comm
                cp -rf ${LOCAL_DIR}/install_comm_dist/lib ${INSTALL_COMPOENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi

                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/llt/include/*
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/llt/lib/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/include ${INSTALL_COMPOENT_PATH_NAME}/llt
                cp -rf ${LOCAL_DIR}/install_comm_dist/lib ${INSTALL_COMPOENT_PATH_NAME}/llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPOENT_PATH_NAME}/llt\" failed."
                fi
                ;;
            release) ;;

            llt) ;;

            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] thrift dist using \"${COMPILE_TYPE}\" has been finished!"
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
                cp -r ${LOCAL_DIR}/install/comm/include ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install/comm/lib ${LOCAL_DIR}/install_comm_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            debug) ;;

            llt) ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] thrift shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

#######################################################################
# build and install component
#######################################################################
function build_component() {
    rm -rf ${LOCAL_DIR}/install* ${SOURCE_CODE_PATH}

    export BOOST_HOME=$ROOT_DIR/binarylibs/dependency/$PLAT_FORM_STR/boost/comm
    export OPENSSL_HOME=$ROOT_DIR/binarylibs/dependency/$PLAT_FORM_STR/openssl/comm
    export C_INCLUDE_PATH=$ROOT_DIR/binarylibs/dependency/$PLAT_FORM_STR/openssl/comm/include:$C_INCLUDE_PATH
    export LD_LIBRARY_PATH=$ROOT_DIR/binarylibs/dependency/$PLAT_FORM_STR/openssl/comm/lib:$ROOT_DIR/binarylibs/dependency/$PLAT_FORM_STR/boost/comm/lib:$LD_LIBRARY_PATH
    export LIBRARY_PATH=$ROOT_DIR/binarylibs/dependency/$PLAT_FORM_STR/openssl/comm/lib:$ROOT_DIR/binarylibs/dependency/$PLAT_FORM_STR/boost/comm/lib:$LIBRARY_PATH

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] thrift Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] thrift not supported build type."
                ;;
            debug)
                die "[Error] thrift not supported build type."
                ;;
            llt)
                cd ${LOCAL_DIR}
                if [ -d ${LOCAL_DIR}/${SOURCE_CODE_PATH} ]; then
                    rm -rf ${LOCAL_DIR}/${SOURCE_CODE_PATH}
                fi
                tar -zxvf ${TAR_FILE_NAME}
                cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
                if [ $? -ne 0 ]; then
                    die "[Error] change dir to ${LOCAL_DIR}/${SOURCE_CODE_PATH} failed."
                fi
                rm -rf ${LOCAL_DIR}/install_llt
                mkdir ${LOCAL_DIR}/install_llt
                mkdir -p ${LOCAL_DIR}/install/${COMPILE_TYPE}
                ./bootstrap.sh
                patch -p0 < ../huawei_thrift_0.13.0.patch
                ./configure --with-cpp --without-java --without-python --with-boost=$BOOST_HOME --with-openssl=$OPENSSL_HOME --with-go=no --with-qt4=no --with-qt5=no --with-zlib=no CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -fPIC" LIBS="-lcrypto -ldl" --enable-static=yes --enable-shared=no --enable-tutorial=no --enable-tests=no --prefix=${LOCAL_DIR}/install_llt
                ;;
            release_llt)
                die "[Error] thrift not supported build type."
                ;;
            debug_llt)
                die "[Error] thrift not supported build type."
                ;;
            comm)
                cd ${LOCAL_DIR}
                if [ -d ${LOCAL_DIR}/${SOURCE_CODE_PATH} ]; then
                    rm -rf ${LOCAL_DIR}/${SOURCE_CODE_PATH}
                fi
                tar -zxvf ${TAR_FILE_NAME}
                cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
                if [ $? -ne 0 ]; then
                    die "[Error] change dir to ${LOCAL_DIR}/${SOURCE_CODE_PATH} failed."
                fi
                rm -rf ${LOCAL_DIR}/install_comm
                mkdir ${LOCAL_DIR}/install_comm
                mkdir -p ${LOCAL_DIR}/install/${COMPILE_TYPE}
                ./bootstrap.sh
                patch -p0 < ../huawei_thrift_0.13.0.patch
                ./configure --with-cpp --without-java --without-python --with-boost=$BOOST_HOME --with-openssl=$OPENSSL_HOME --with-go=no --with-qt4=no --with-qt5=no --with-zlib=no CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -fPIC" LIBS="-lcrypto -ldl" --enable-static=yes --enable-shared=no --enable-tutorial=no --enable-tests=no --prefix=${LOCAL_DIR}/install_comm
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] thrift configure failed."
        fi
        log "[Notice] thrift End configure"

        log "[Notice] thrift using \"${COMPILE_TYPE}\" Begin make"
        make -j4
        if [ $? -ne 0 ]; then
            die "thrift make failed."
        fi
        log "[Notice] thrift End make"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] thrift make install failed."
        fi
        log "[Notice] thrift using \"${COMPILE_TYPE}\" End make install"

        cp -r $LOCAL_DIR/install_${COMPILE_TYPE}/* ${LOCAL_DIR}/install/${COMPILE_TYPE}
        log "[Notice] thrift build using \"${COMPILE_TYPE}\" has been finished"
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

    make clean

    cd ${LOCAL_DIR}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR} failed."
    fi
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf ${SOURCE_CODE_PATH}
    rm -rf install_*

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
