#!/bin/bash
#  Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
#  description: the script that make install libevent
#  date: 2020-06-08
#  version: -1.0
#  history:
#    2020-06-08 100 LOC.

set -e
python $(pwd)/../../build/pull_open_source.py "libevent" "libevent-2.1.11-stable.tar.gz" "05833LTP"

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
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)
ROOT_DIR="${LOCAL_DIR}/../../"
SSL_LIB="${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/openssl/comm/lib"
SSL_INCLUDE="${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/openssl/comm/include"
INSTALL_COMPOENT_PATH_NAME="${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/event"

log()
{
    echo "[Build libevent] "$(date +%y-%m-%d" "%T)": $@"
    echo "[Build libevent] "$(date +%y-%m-%d" "%T)": $@" >> "$LOG_FILE" 2>&1
}

function build_component()
{
    cd ${LOCAL_DIR}
    tar -xvf ${TAR_FILE_NAME}
    patch -p0 < ${PATCH_FILE_NAME}

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    chmod +x configure

    mkdir -p ${LOCAL_DIR}/install_comm
    log "[Notice] event configure string: ./configure CFLAGS='-O2 -g3' --enable-static=yes --enable-shared=no --with-pic=false CFLAGS='-fPIE' --prefix=${LOCAL_DIR}/install_comm"
    ./configure CFLAGS='-O2 -g3' --enable-static=yes --enable-shared=no --with-pic=false CFLAGS='-fPIE' CPPFLAGS=-I${SSL_INCLUDE} LDFLAGS=-L${SSL_LIB} --prefix=${LOCAL_DIR}/install_comm
    make -j4
    make install
    make clean

    mkdir -p ${LOCAL_DIR}/install_llt
    log "[Notice] event configure string: ./configure CFLAGS='-O2 -g3' --enable-static=yes --enable-shared=no --with-pic=false CFLAGS='-fPIE' --prefix=${LOCAL_DIR}/install_llt"
    ./configure CFLAGS='-O2 -g3' --enable-static=yes --enable-shared=no --with-pic=false CFLAGS='-fPIE' CPPFLAGS=-I${SSL_INCLUDE} LDFLAGS=-L${SSL_LIB} --prefix=${LOCAL_DIR}/install_llt
    make -j4
    make install
    make clean
}

function shrink_component()
{
    mkdir ${LOCAL_DIR}/install_comm_dist
    cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist
    mkdir ${LOCAL_DIR}/install_llt_dist
    cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist
    mv ${LOCAL_DIR}/install_llt_dist/lib/libevent.a ${LOCAL_DIR}/install_llt_dist/lib/libevent_pic.a
}

function dist_component()
{
    mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/comm 
    rm -rf "${INSTALL_COMPOENT_PATH_NAME}"/comm/*
    cp -r ${LOCAL_DIR}/install_comm_dist/* "${INSTALL_COMPOENT_PATH_NAME}"/comm
    mkdir -p ${INSTALL_COMPOENT_PATH_NAME}/llt
    rm -rf "${INSTALL_COMPOENT_PATH_NAME}"/llt/*
    cp -r ${LOCAL_DIR}/install_llt_dist/* "${INSTALL_COMPOENT_PATH_NAME}"/llt
}

function clean_component()
{
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    make clean
    cd ${LOCAL_DIR}
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf "${SOURCE_CODE_PATH}"
    rm -rf install_*
}

function main()
{
    build_component
    shrink_component
    dist_component
    clean_component
}

main
