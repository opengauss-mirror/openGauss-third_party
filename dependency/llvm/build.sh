#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2020. All rights reserved.
#  description: the script that make install llvm libs
#  date: 2015-9-15
#  modified: 2019-1-29
#  version: 2.0
#  history:

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
TAR_FILE_NAME=llvm-7.0.0.src.tar
SOURCE_CODE_PATH=llvm-7.0.0.src
LOG_FILE=${LOCAL_DIR}/build_llvm-7.0.0.log
BUILD_PATH=build
BUILD_FAILED=1

#######################################################################
## print help information
#######################################################################
function print_help() {
    echo "Usage: $0 [OPTION]
        -h|--help               show help information
        -m|--build_option       provide type of operation, values of paramenter is build, shrink, dist or clean
    -t|--build_target    provide type of platform, values of parameter is X86 or AArch64
    "
}

#######################################################################
#  Print log.
#######################################################################
log() {
    echo "[Build llvm] $(date +%y-%m-%d" "%T): $@"
    echo "[Build llvm] $(date +%y-%m-%d" "%T): $@" >> "$LOG_FILE" 2>&1
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
INSTALL_COMPONENT_PATH_NAME="${ROOT_DIR}/${COMPONENT_TYPE}/${PLAT_FORM_STR}/${COMPONENT_NAME}"

#######################################################################
# build and install component
#######################################################################
function build_component() {
    cd ${LOCAL_DIR}
    xz -d "${TAR_FILE_NAME}.xz"
    tar -xvf ${TAR_FILE_NAME}

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    patch -p1 < ../huawei_llvm.patch

    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi
    rm -rf ${LOCAL_DIR}/build
    mkdir ${LOCAL_DIR}/build
    cd ${LOCAL_DIR}/build
    log "[Notice] llvm start configure"

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] llvm not supported build type."
                ;;
            debug)
                die "[Error] llvm not supported build type."
                ;;
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm
                log "[Notice] llvm cmake string: cmake -G "Unix Makefiles" -DCMAKE_CXX_FLAGS='-fno-aggressive-loop-optimizations -D_GLIBCXX_USE_CXX11_ABI=0 -fexceptions' -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=${BUILD_TARGET} -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_C_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_comm ../${SOURCE_CODE_PATH}"
                cmake -G "Unix Makefiles" -DCMAKE_CXX_FLAGS='-fno-aggressive-loop-optimizations -D_GLIBCXX_USE_CXX11_ABI=0 -fexceptions' -DCMAKE_C_FLAGS='-fno-aggressive-loop-optimizations -fexceptions' -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=${BUILD_TARGET} -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_C_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_comm ../${SOURCE_CODE_PATH}
                ;;
            release_llt)
                die "[Error] llvm not supported build type."
                ;;
            debug_llt)
                die "[Error] llvm not supported build type."
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt
                log "[Notice] llvm cmake string: cmake -G "Unix Makefiles" -DCMAKE_CXX_FLAGS='-fno-aggressive-loop-optimizations -D_GLIBCXX_USE_CXX11_ABI=0' -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=${BUILD_TARGET} -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_C_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_comm ../${SOURCE_CODE_PATH}"
                cmake -G "Unix Makefiles" -DCMAKE_CXX_FLAGS='-fno-aggressive-loop-optimizations -D_GLIBCXX_USE_CXX11_ABI=0 -fexceptions' -DCMAKE_C_FLAGS='-fno-aggressive-loop-optimizations -fexceptions' -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=${BUILD_TARGET} -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_C_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_llt ../${SOURCE_CODE_PATH}
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] llvm configure failed."
        fi
        log "[Notice] llvm End configure"

        log "[Notice] llvm using \"${COMPILE_TYPE}\" Begin make"
        make -j4
        if [ $? -ne 0 ]; then
            die "llvm make failed."
        fi
        log "[Notice] llvm End make"

        log "[Notice] llvm using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "llvm make install failed."
        fi
        log "[Notice] llvm End make install"
        # llvm has no distclean, using clean here.
        make clean
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
                cp ${LOCAL_DIR}/install_comm/include ${LOCAL_DIR}/install_comm_dist/ -r
                cp ${LOCAL_DIR}/install_comm/lib ${LOCAL_DIR}/install_comm_dist/ -r
                cp ${LOCAL_DIR}/install_comm/bin ${LOCAL_DIR}/install_comm_dist/ -r
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist
                cp ${LOCAL_DIR}/install_llt/include ${LOCAL_DIR}/install_llt_dist/ -r
                cp ${LOCAL_DIR}/install_llt/lib ${LOCAL_DIR}/install_llt_dist/ -r
                cp ${LOCAL_DIR}/install_llt/bin ${LOCAL_DIR}/install_llt_dist/ -r
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
#    we could makesure that $INSTALL_COMPNOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir -p ${INSTALL_COMPONENT_PATH_NAME}/comm
                rm -rf ${INSTALL_COMPONENT_PATH_NAME}/comm/*
                mkdir -p ${INSTALL_COMPONENT_PATH_NAME}
                mkdir -p ${INSTALL_COMPONENT_PATH_NAME}/comm
                cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPONENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPONENT_PATH_NAME}/comm\" failed."
                fi
                ;;
            release) ;;

            debug) ;;

            llt)
                mkdir -p ${INSTALL_COMPONENT_PATH_NAME}/llt
                rm -rf ${INSTALL_COMPONENT_PATH_NAME}/llt/*
                mkdir -p ${INSTALL_COMPONENT_PATH_NAME}/llt
                cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPONENT_PATH_NAME}/llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPONENT_PATH_NAME}/llt\" failed."
                fi
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] llvm dist using \"${COMPILE_TYPE}\" has been finished!"
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
while getopts "h:m:t:" opt; do
    case "$opt" in
        m)
            if [[ "$OPTARG"X = ""X ]]; then
                die "no given version info"
            fi
            if [[ $# -lt 2 ]]; then
                die "not enough params"
            fi
            BUILD_OPTION=$OPTARG
            ;;
        t)
            if [[ "$OPTARG"X != "X86"X ]] && [[ "$OPTARG"X != "AArch64"X ]]; then
                die "not correct platform"
            fi
            if [[ $# -lt 2 ]]; then
                die "not enough params"
            fi
            BUILD_TARGET=$OPTARG
            ;;
        *)
            log "Internal Error: option processing error: $1" 1>&2
            log "please input right paramtenter, the following command may help you"
            log "./build.sh"
            exit 1
            ;;
    esac
done

###########################################################################
main
