#!/bin/bash
# Copyright (c): 2020, Huawei Tech. Co., Ltd.
#  description: the script that make install zlib
#  date: 2015-8-20
#  version: 1.0
#  history:
#    2015-12-19 update to zlib1.2.8
#    2017-04-21 update to zlib1.2.11

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

TAR_FILE_NAME=zlib-1.2.11.tar.gz
SOURCE_CODE_PATH=zlib-1.2.11

LOG_FILE=${LOCAL_DIR}/build_zlib.log
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
    echo "[Build zlib] $(date +%y-%m-%d' '%T): $@"
    echo "[Build zlib] $(date +%y-%m-%d' '%T): $@" >> "$LOG_FILE" 2>&1
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

ROOT_DIR="${LOCAL_DIR}/../../.."
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

    chmod +x configure
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] zlib Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] zlib not supported build type."
                ;;
            debug)
                die "[Error] zlib not supported build type."
                ;;
            release_llt)
                die "[Error] zlib not supported build type."
                ;;
            debug_llt)
                die "[Error] zlib not supported build type."
                ;;
            comm | llt)
                CONFIGURE_EXTRA_FLAG="--64"
                if [[ X"${PLAT_FORM_STR}" == X*"aarch64" ]]; then
                    CONFIGURE_EXTRA_FLAG=""
                fi
                mkdir -p ${LOCAL_DIR}/install_${COMPILE_TYPE}
                log "[Notice] zlib configure string: ./configure ${CONFIGURE_EXTRA_FLAG} --prefix=${LOCAL_DIR}/install_${COMPILE_TYPE}"
                ./configure ${CONFIGURE_EXTRA_FLAG} --prefix=${LOCAL_DIR}/install_${COMPILE_TYPE}
                sed -i '21a CFLAGS += -fPIC' Makefile

                if [ $? -ne 0 ]; then
                    die "[Error] zlib configure failed."
                fi
                log "[Notice] zlib End configure"

                log "[Notice] zlib using \"${COMPILE_TYPE}\" Begin make"

                MAKE_EXTRA_FLAG="-m64"
                if [[ X"${PLAT_FORM_STR}" == X*"aarch64" ]]; then
                    MAKE_EXTRA_FLAG=""
                fi
                if [ "${COMPILE_TYPE}"X = "comm"X ]; then
                    make CFLAGS="-fPIE" SFLAGS="-O2 -fPIC -fstack-protector-strong -Wl,-z,noexecstack -Wl,-z,relro,-z,now ${MAKE_EXTRA_FLAG} -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN" -j4
                else
                    make CFLAGS="-O3 -fPIE ${MAKE_EXTRA_FLAG} -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDD" SFLAGS="-O3 -fPIC -fstack-protector-strong -Wl,-z,noexecstack -Wl,-z,relro,-z,now ${MAKE_EXTRA_FLAG} -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN" -j4
                fi
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "zlib make failed."
        fi
        log "[Notice] zlib End make"

        log "[Notice] zlib using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] zlib make install failed."
        fi
        log "[Notice] zlib using \"${COMPILE_TYPE}\" End make install"

        ######### make libminiunz ########
        log "[Notice] make and install libminiunz before zlib clean "
        log "[Notice] copying makefile and patches"
        cp ../Makefile.miniunz contrib/minizip/
        cp ../huawei_unzip_alloc_hook.patch contrib/minizip/
        cp ../huawei_unzip_alloc_hook.patch2 contrib/minizip/

        log "[Notice] enter contrib/minizip/"
        cd contrib/minizip/

        case "${COMPILE_TYPE}" in
            comm)
                log "[Notice] patching unzip.h"
                patch -N unzip.h huawei_unzip_alloc_hook.patch2
                if [ $? -ne 0 ]; then
                    die "failed to patch unzip.h for memory hook."
                fi

                log "[Notice] patching unzip.c"
                patch -N unzip.c huawei_unzip_alloc_hook.patch
                if [ $? -ne 0 ]; then
                    die "failed to patch unzip.c for memory hook."
                fi
                ;;
            llt) ;;

        esac

        log "[Notice] make libminiunz"
        make -f Makefile.miniunz
        if [ $? -ne 0 ]; then
            die "failed to make libminiunz."
        fi

        ######### make install libminiunz ########
        log "[Notice] make install libminiunz"
        make install -f Makefile.miniunz DESTDIR=${LOCAL_DIR}/install_${COMPILE_TYPE}
        if [ $? -ne 0 ]; then
            die "[Error] libminiunz make install failed."
        fi

        ######### make install libminiunz ########
        log "[Notice] make clean libminiunz"
        make clean -f Makefile.miniunz
        log "[Notice] exit contrib/minizip/"
        cd ../..

        make clean
        log "[Notice] zlib build using \"${COMPILE_TYPE}\" has been finished"
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
                cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist
                cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist\" failed."
                fi
                mv ${LOCAL_DIR}/install_llt_dist/lib/libz.so ${LOCAL_DIR}/install_llt_dist/lib/libz_pic.so
                ;;
            debug) ;;

            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] zlib shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#	we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm/
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/comm/*
                cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi
                ;;
            llt)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt/
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
        log "[Notice] zlib dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] zlib clean has been finished!"
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
