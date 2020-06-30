#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2020. All rights reserved.
#  description: the script that make install psutil libs
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
LOG_FILE=${LOCAL_DIR}/build_psutil.log
BUILD_FAILED=1
TAR_FILE_NAME=psutil-5.6.1.tar.gz
SOURCE_CODE_PATH=psutil-5.6.1
DEPENDENCY_PATH=$(dirname "${LOCAL_DIR}")

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
INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/${COMPONENT_TYPE}/${PLAT_FORM_STR}/install_tools/${COMPONENT_NAME}"

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
    echo "[Copy psutil libs] $(date +%y-%m-%d" "%T): $@"
    echo "[Copy psutil libs] $(date +%y-%m-%d" "%T): $@" >> "$LOG_FILE" 2>&1
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
	rm -rf ${SOURCE_CODE_PATH}
	tar -xvf ${TAR_FILE_NAME}
	
	cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to ${LOCAL_DIR}/${SOURCE_CODE_PATH} failed."
    fi
	patch -p1 < ../CVE-2019-18874.patch || true
	chmod +x setup.py
	
	python_version=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
	if [ "X${python_version}" != "X3" ]; then
		die "[Error] need python 3.x, please check your python version."
	fi
	
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        log "[Notice] psutil Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] psutil not supported build type."
                ;;
            debug)
                die "[Error] psutil not supported build type."
                ;;
            comm)
                log "[Notice] psutil build string: python setup.py build"
                mkdir -p ${DEPENDENCY_PATH}/install_comm
				export PYTHONPATH=${DEPENDENCY_PATH}/install_comm
				
                python setup.py build
				if [ $? -ne 0 ]; then
					die "[Error] psutil excute cmd python setup.py build failed."
				fi
				
				python setup.py install --install-lib=${DEPENDENCY_PATH}/install_comm
				if [ $? -ne 0 ]; then
					die "[Error] psutil python setup.py install --install-lib=${DEPENDENCY_PATH}/install_comm."
				fi
                ;;
            release_llt)
                die "[Error] psutil not supported build type."
                ;;
            debug_llt)
                die "[Error] psutil not supported build type."
                ;;
            llt)
                log "[Notice] psutil build string: python setup.py build"
                mkdir -p ${DEPENDENCY_PATH}/install_comm
				export PYTHONPATH=${DEPENDENCY_PATH}/install_comm
				
                python setup.py build
				if [ $? -ne 0 ]; then
					die "[Error] psutil excute cmd python setup.py build failed."
				fi
				
				python setup.py install --install-lib=${DEPENDENCY_PATH}/install_comm
				if [ $? -ne 0 ]; then
					die "[Error] psutil python setup.py install --install-lib=${DEPENDENCY_PATH}/install_comm."
				fi
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
                ;;
        esac

        if [ $? -ne 0 ]; then
            die "[Error] psutil libs copy failed."
        fi
        log "[Notice] psutil libs End copy"
    done
}

##############################################################################################################
# dist the real files to the matched path
#we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component() {
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}; do
        case "${COMPILE_TYPE}" in
            debug) ;;
            release) ;;

            comm) 
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/*
                cp -rf ${LOCAL_DIR}/${SOURCE_CODE_PATH}/build/lib.*/psutil/* ${INSTALL_COMPOENT_PATH_NAME}/
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -rf ${LOCAL_DIR}/${SOURCE_CODE_PATH}/build/lib.*/psutil/* ${INSTALL_COMPOENT_PATH_NAME}/\" failed."
                fi
				if [ -d ${INSTALL_COMPOENT_PATH_NAME}/tests ];then
					rm -rf ${INSTALL_COMPOENT_PATH_NAME}/tests
					if [ $? -ne 0 ]; then
						die "[Error] \"cp -f ${LOCAL_DIR}/${SOURCE_CODE_PATH}/build/lib.*/psutil.*.so ${INSTALL_COMPOENT_PATH_NAME}/psutil.so_UCS2\" failed."
					fi
				fi
				cp -f ${INSTALL_COMPOENT_PATH_NAME}/_psutil_linux.*.so ${INSTALL_COMPOENT_PATH_NAME}/_psutil_linux.so_3.6
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -f ${INSTALL_COMPOENT_PATH_NAME}/_psutil_linux.*.so ${INSTALL_COMPOENT_PATH_NAME}/_psutil_linux.so_3.6\" failed."
                fi
				mv ${INSTALL_COMPOENT_PATH_NAME}/_psutil_linux.*.so ${INSTALL_COMPOENT_PATH_NAME}/_psutil_linux.so_3.7
                if [ $? -ne 0 ]; then
                    die "[Error] \"mv ${INSTALL_COMPOENT_PATH_NAME}/_psutil_linux.*.so ${INSTALL_COMPOENT_PATH_NAME}/_psutil_linux.so_3.7\" failed."
                fi
				cp -f ${INSTALL_COMPOENT_PATH_NAME}/_psutil_posix.*.so ${INSTALL_COMPOENT_PATH_NAME}/_psutil_posix.so_3.6
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -f ${INSTALL_COMPOENT_PATH_NAME}/_psutil_posix.*.so ${INSTALL_COMPOENT_PATH_NAME}/_psutil_posix.so_3.6\" failed."
                fi
				mv ${INSTALL_COMPOENT_PATH_NAME}/_psutil_posix.*.so ${INSTALL_COMPOENT_PATH_NAME}/_psutil_posix.so_3.7
                if [ $? -ne 0 ]; then
                    die "[Error] \"mv ${INSTALL_COMPOENT_PATH_NAME}/_psutil_posix.*.so ${INSTALL_COMPOENT_PATH_NAME}/_psutil_posix.so_3.7\" failed."
                fi
                ;;

            llt) ;;
            release_llt) ;;

            debug_llt) ;;

            *) ;;
        esac
        log "[Notice] psutil libs dist using \"${COMPILE_TYPE}\" has been finished!"
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

    log "[Notice] psutil libs clean has been finished!"
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
        dist)
            dist_component
            ;;
        clean)
            clean_component
            ;;
        all)
            build_component
            dist_component
            ;;
        *)
            log "Internal Error: option processing error: $2"
            log "please input right paramenter values build, dist or clean "
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
