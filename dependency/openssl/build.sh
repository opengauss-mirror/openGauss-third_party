#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2020. All rights reserved.
# description: the script that make install openssl
# date: 2020-03-24
# version: 1.0
# history: 2020-03-24: first version

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

TAR_FILE_NAME=openssl-1.1.1d.tar.gz
SOURCE_CODE_PATH=openssl-1.1.1d
PATCHFILE=CVE-2019-1551.patch

LOG_FILE=${LOCAL_DIR}/build_openssl.log
BUILD_FAILED=1

#######################################################################
#  print log and exit.
#######################################################################
die() {
    log "$@"
    echo "$@"
    exit $BUILD_FAILED
}

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
    echo "[Build openssl] $(date +%y-%m-%d' '%T): $@"
    echo "[Build openssl] $(date +%y-%m-%d' '%T): $@" >> "$LOG_FILE" 2>&1
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
    rm -rf ${LOCAL_DIR}/install* ${SOURCE_CODE_PATH}
    cd ${LOCAL_DIR}
    tar -xvf ${TAR_FILE_NAME}

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    patch -Np1 < ../${PATCHFILE}
    patch -Np1 < ../CVE-2020-1967.patch

    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] openssl Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] openssl not supported build type."
                ;;
            debug)
                die "[Error] openssl not supported build type."
                ;;
            llt)
                rm -rf $LOCAL_DIR/install_llt
                mkdir -p $LOCAL_DIR/install_llt
                mkdir -p ${LOCAL_DIR}/install/${COMPILE_TYPE}
                if [ ${PLAT_FORM_STR} = "openeuler_aarch64" ] || [ ${PLAT_FORM_STR} = "openeuler_x86_64" ] || [ ${PLAT_FORM_STR} = "euleros2.0_sp8_aarch64" ] || [ ${PLAT_FORM_STR} = "neokylin_aarch64" ] || [ ${PLAT_FORM_STR} = "kylin_aarch64" ]; then
                    log "[Notice] openssl configure string: ./config -fPIE -fPIC -pie -shared -fstack-protector-strong -g -O2 -Wl,-z,relro,-z,now --prefix=$LOCAL_DIR/install_llt --openssldir=$LOCAL_DIR/install_llt zlib -L=$LOCAL_DIR/../zlib/install_comm/lib enable-camellia enable-seed enable-rfc3779 enable-cms enable-md2 enable-rc5 enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers no-mdc2 no-ec2m enable-sm2 enable-sm4 "
                    ./config -fPIE -fPIC -pie -shared -fstack-protector-strong -g -O2 -Wl,-z,relro,-z,now --prefix=$LOCAL_DIR/install_llt --openssldir=$LOCAL_DIR/install_llt zlib -L$LOCAL_DIR/../zlib/install_comm/lib -I$LOCAL_DIR/../zlib/install_comm/include enable-camellia enable-seed enable-rfc3779 enable-cms enable-md2 enable-rc5 enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers no-mdc2 no-ec2m enable-sm2 enable-sm4 
                else
                    log "[Notice] openssl configure string: ./config -fPIE -fPIC -pie -shared -fstack-protector-strong -g -O2 -Wl,-z,relro,-z,now --prefix=$LOCAL_DIR/install_llt --openssldir=$LOCAL_DIR/install_llt -L=$LOCAL_DIR/../zlib/install_comm/lib"
                    ./config -fPIE -fPIC -pie -shared -fstack-protector-strong -g -O2 -Wl,-z,relro,-z,now --prefix=$LOCAL_DIR/install_llt --openssldir=$LOCAL_DIR/install_llt -L$LOCAL_DIR/../zlib/install_comm/lib -I$LOCAL_DIR/../zlib/install_comm/include
                fi
                ;;
            release_llt)
                die "[Error] openssl not supported build type."
                ;;
            debug_llt)
                die "[Error] openssl not supported build type."
                ;;
            comm)
                rm -rf $LOCAL_DIR/install_comm
                mkdir -p $LOCAL_DIR/install_comm
                mkdir -p ${LOCAL_DIR}/install/${COMPILE_TYPE}
                if [ ${PLAT_FORM_STR} = "openeuler_aarch64" ] || [ ${PLAT_FORM_STR} = "openeuler_x86_64" ] || [ ${PLAT_FORM_STR} = "euleros2.0_sp8_aarch64" ] || [ ${PLAT_FORM_STR} = "neokylin_aarch64" ] || [ ${PLAT_FORM_STR} = "kylin_aarch64" ]; then
                    log "[Notice] openssl configure string: ./config -fPIE -fpIC -pie -shared -fstack-protector-strong -g -O2 -Wl,-z,relro,-z,now --prefix=$LOCAL_DIR/install_comm --openssldir=$LOCAL_DIR/install_comm zlib enable-camellia enable-seed enable-rfc3779 enable-sctp enable-cms enable-md2 enable-rc5 enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers no-mdc2 no-ec2m enable-sm2 enable-sm4 "
                    ./config -fPIE -fPIC -pie -shared -fstack-protector-strong -g -O2 -Wl,-z,relro,-z,now --prefix=$LOCAL_DIR/install_comm --openssldir=$LOCAL_DIR/install_comm zlib -L$LOCAL_DIR/../zlib/install_comm/lib -I$LOCAL_DIR/../zlib/install_comm/include enable-camellia enable-seed enable-rfc3779 enable-cms enable-md2 enable-rc5 enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers no-mdc2 no-ec2m enable-sm2 enable-sm4 
                else
                    log "[Notice] openssl configure string: ./config -fPIE -fpIC -pie -shared -fstack-protector-strong -g -O2 -Wl,-z,relro,-z,now --prefix=$LOCAL_DIR/install_comm --openssldir=$LOCAL_DIR/install_comm"
                    ./config -fPIE -fPIC -pie -shared -fstack-protector-strong -g -O2 -Wl,-z,relro,-z,now --prefix=$LOCAL_DIR/install_comm --openssldir=$LOCAL_DIR/install_comm -L$LOCAL_DIR/../zlib/install_comm/lib -I$LOCAL_DIR/../zlib/install_comm/include
                fi
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] openssl configure failed."
        fi
        log "[Notice] openssl End configure"

        log "[Notice] openssl using \"${COMPILE_TYPE}\" Begin make"
        make -j4
        if [ $? -ne 0 ]; then
            die "openssl make failed."
        fi
        log "[Notice] openssl End make"

        log "[Notice] openssl using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] openssl make install failed."
        fi
        log "[Notice] openssl using \"${COMPILE_TYPE}\" End make install"

        cp -r $LOCAL_DIR/install_${COMPILE_TYPE}/* ${LOCAL_DIR}/install/${COMPILE_TYPE}
        make clean
        log "[Notice] openssl build using \"${COMPILE_TYPE}\" has been finished"
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
                cp -r ${LOCAL_DIR}/install/comm/bin ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install/comm/include ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install/comm/lib ${LOCAL_DIR}/install_comm_dist
                # cp -r ${LOCAL_DIR}/install/llt/bin ${LOCAL_DIR}/install_comm_dist
                # cp -r ${LOCAL_DIR}/install/llt/lib/libssl.a ${LOCAL_DIR}/install_comm_dist/lib
                # cp -r ${LOCAL_DIR}/install/llt/lib/libcrypto.a ${LOCAL_DIR}/install_comm_dist/lib
                mv ${LOCAL_DIR}/install_comm_dist/lib/libssl.a ${LOCAL_DIR}/install_comm_dist/lib/libssl_static.a
                mv ${LOCAL_DIR}/install_comm_dist/lib/libcrypto.a ${LOCAL_DIR}/install_comm_dist/lib/libcrypto_static.a
                rm -r ${LOCAL_DIR}/install_comm_dist/lib/engines-1.1
                rm -r ${LOCAL_DIR}/install_comm_dist/lib/pkgconfig

                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            debug) ;;

            llt)
                cp -r ${LOCAL_DIR}/install/llt/bin ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install/llt/lib/libssl.a ${LOCAL_DIR}/install_comm_dist/lib
                cp -r ${LOCAL_DIR}/install/llt/lib/libcrypto.a ${LOCAL_DIR}/install_comm_dist/lib
                ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] openssl shrink using \"${COMPILE_TYPE}\" has been finished!"
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
                log "[Notice] INSTALL_COMPOENT_PATH_NAME: \"${INSTALL_COMPOENT_PATH_NAME}\" "
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/bin/*
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/include/*
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/lib/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/bin ${INSTALL_COMPOENT_PATH_NAME}/comm
                cp -rf ${LOCAL_DIR}/install_comm_dist/include ${INSTALL_COMPOENT_PATH_NAME}/comm
                cp -rf ${LOCAL_DIR}/install_comm_dist/lib ${INSTALL_COMPOENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi
                ;;
            release) ;;

            llt) ;;

            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] openssl dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] openssl clean has been finished!"
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
            log "please input right paramenter values build, shrink, dist or clean"
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
