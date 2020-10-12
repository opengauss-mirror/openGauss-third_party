#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install arrow
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
set -e

######################################################################
# Parameter setting
######################################################################
ZIP_FILE_NAME=apache-arrow-0.11.1.zip
SOURCE_CODE_PATH=arrow-apache-arrow-0.11.1

SCRIPT_PATH=$(
    cd $(dirname $0)
    pwd
)

CONFIG_FILE_NAME=config.ini

# dependencies path
LIB_ROOT_PATH="${SCRIPT_PATH}/../"
ROOT_DIR="${SCRIPT_PATH}/../../.."
BUILD_TARGET=$(echo ${SCRIPT_PATH} | awk -F "/" '{print $NF}')

BUILD_LOG_FILE=${SCRIPT_PATH}/build_${BUILD_TARGET}.log
LOG_FILE=${SCRIPT_PATH}/${BUILD_TARGET}.log

BUILD_FAILED=1
FORMART_SIZE=100

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

function init_dependencies() {
    export BOOST_ROOT=${LIB_ROOT_PATH}/boost/install_comm
    export ZLIB_HOME=${LIB_ROOT_PATH}/zlib/install_comm
    export THRIFT_HOME=${LIB_ROOT_PATH}/libthrift/install_comm
    export LZ4_HOME=${LIB_ROOT_PATH}/lz4/install_comm
    export DOUBLE_CONVERSION_HOME=${LIB_ROOT_PATH}/double-conversion/install_comm
    export BROTLI_HOME=${LIB_ROOT_PATH}/brotli/install_comm
    export SNAPPY_HOME=${LIB_ROOT_PATH}/snappy/install_comm
    export ZSTD_HOME=${LIB_ROOT_PATH}/zstd/install_comm
    export GLOG_HOME=${LIB_ROOT_PATH}/glog/install_comm
    export FLATBUFFERS_HOME=${LIB_ROOT_PATH}/flatbuffers/install_comm
    export RAPIDJSON_HOME=${LIB_ROOT_PATH}/rapidjson/install_comm/include
    export LD_LIBRARY_PATH=${LIB_ROOT_PATH}/openssl/install_comm/lib:${LD_LIBRARY_PATH}
}

#######################################################################
# build and install component
#######################################################################
function build_component() {
    cd ${SCRIPT_PATH}

    if [ $? -ne 0 ]; then
        die "[Error] change dir to ${SCRIPT_PATH} failed."
    fi

    export PKG_CONFIG_PATH=${SCRIPT_PATH}/pkgconfig
    rm -rf ${SCRIPT_PATH}/${SOURCE_CODE_PATH} ${SCRIPT_PATH}/pkgconfig
    init_dependencies
    unzip -o ${ZIP_FILE_NAME} > ${LOG_FILE}
    cd ${SCRIPT_PATH}/${SOURCE_CODE_PATH}
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] arrow Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] arrow not supported build type."
                ;;
            debug)
                die "[Error] arrow not supported build type."
                ;;
            llt)
                die "[Error] arrow not supported build type."
                ;;
            release_llt)
                die "[Error] arrow not supported build type."
                ;;
            debug_llt)
                die "[Error] arrow not supported build type."
                ;;
            comm)
                mkdir -p ${SCRIPT_PATH}/install_comm
                rm -rf cpp/build
                mkdir -p cpp/build/install
                cd cpp/build
                cp ${RAPIDJSON_HOME}/rapidjson ../src/ -rf
                sed -i "17a #include <cmath> " ../src/parquet/statistics.cc
                sed -i "471d" ../cmake_modules/ThirdpartyToolchain.cmake
                sed -i "472a set(DOUBLE_CONVERSION_INCLUDE_DIR "${DOUBLE_CONVERSION_HOME}/include")" ../cmake_modules/ThirdpartyToolchain.cmake
                sed -i "473a set(DOUBLE_CONVERSION_STATIC_LIB "${DOUBLE_CONVERSION_HOME}/lib/libdouble-conversion.a")" ../cmake_modules/ThirdpartyToolchain.cmake
                sed -i "430a set(BOOST_SHARED_SYSTEM_LIBRARY ${BOOST_ROOT}/lib/libboost_system.a)" ../cmake_modules/ThirdpartyToolchain.cmake
                sed -i "431a set(BOOST_SHARED_FILESYSTEM_LIBRARY ${BOOST_ROOT}/lib/libboost_filesystem.a)" ../cmake_modules/ThirdpartyToolchain.cmake
                sed -i "432a set(BOOST_SHARED_REGEX_LIBRARY ${BOOST_ROOT}/lib/libboost_regex.a)" ../cmake_modules/ThirdpartyToolchain.cmake
                sed -i "449a include_directories(SYSTEM ${BOOST_ROOT}/include)" ../cmake_modules/ThirdpartyToolchain.cmake
                cmake .. -DCMAKE_BUILD_TYPE=release -DARROW_PARQUET=ON -DARROW_BUILD_TESTS=OFF -DPARQUET_BUILD_EXAMPLES=OFF -DPARQUET_BUILD_EXECUTABLES=OFF -DARROW_WITH_BROTLI=ON -DARROW_WITH_LZ4=ON -DARROW_WITH_SNAPPY=ON -DARROW_WITH_ZLIB=ON -DARROW_WITH_ZSTD=ON -DARROW_BOOST_USE_SHARED=ON -DARROW_IPC=ON -DPARQUET_ARROW_LINKAGE=static -DCMAKE_INSTALL_PREFIX=${SCRIPT_PATH}/install_comm -DCMAKE_CXX_FLAGS="-std=c++11 -Wl,-z,now -fstack-protector-all -D_GLIBCXX_USE_CXX11_ABI=0 $APPEND_FLAGS $APPEND_LDFLAGS" -DCMAKE_C_FLAGS=" $APPEND_FLAGS $APPEND_LDFLAGS -Wl,-z,now -fstack-protector-all" -DARROW_INSTALL_NAME_RPATH=OFF -DPTHREAD_LIBRARY=""
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] arrow configure failed."
        fi
        log "[Notice] arrow End configure"
        log_process "[Notice] arrow using \"${COMPILE_TYPE}\" Begin make"
        make CFLAGS="-O3 -fPIE -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDD" -j4 >> ${BUILD_LOG_FILE} 2>&1
        make parquet -j4 >> ${BUILD_LOG_FILE} 2>&1
        if [ $? -ne 0 ]; then
            die "arrow make failed."
        fi
        log_process_done

        log_process "[Notice] arrow using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] arrow make install failed."
        fi
        log_process_done

        make clean
        log "[Notice] arrow build using \"${COMPILE_TYPE}\" has been finished"
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
                rsync -aH --rsync-path="mkdir -p ${SCRIPT_PATH}/install_${COMPILE_TYPE}/lib && rsync" --delete ${SCRIPT_PATH}/install_${COMPILE_TYPE}/lib64/ ${SCRIPT_PATH}/install_${COMPILE_TYPE}/lib
                [ -e ${SCRIPT_PATH}/install_comm/lib64 ] && rm -rf ${SCRIPT_PATH}/install_comm/lib64
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
        log "[Notice] arrow shrink using \"${COMPILE_TYPE}\" has been finished!"
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
        log "[Notice] arrow dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] arrow clean has been finished!"
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
