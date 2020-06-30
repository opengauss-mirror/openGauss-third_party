#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install buildtools
#  date: 2020-06-01
#  version: 1.0
#  history:
#
# *************************************************************************

export BUILD_SCRIPT_PATH=$(
    cd "$(dirname "$0")"
    pwd
)
export OPEN_SOURCE=$(dirname $BUILD_SCRIPT_PATH)

. ${BUILD_SCRIPT_PATH}/../../build/common.sh

function build_buildtools() {
    build_item gmp
    build_item mpfr
    build_item mpc
    build_item isl
    build_item gcc
    build_item cmake
    # miss
    # build_item libcurl
}

function main() {
    cd $BUILD_SCRIPT_PATH
    if [ ! -f "$BUILD_SCRIPT_PATH/../../buildtools/gcc/gcc-8.2.0.tar.gz" ] \
         && [ ! -f "$BUILD_SCRIPT_PATH/../../buildtools/gcc/gcc-8.2.0.zip" ]; then
        echo "[ERROR]: You should download gcc-8.2.0.tar.gz or gcc-8.2.0.zip and put it in $BUILD_SCRIPT_PATH/../buildtools/gcc/"
        exit 1
    fi
    rm -rf *.log
    total_start_tm=$(date +%s%N)
    build_buildtools
    total_end_tm=$(date +%s%N)
    total_use_tm=$(echo $total_end_tm $total_start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
    echo "total time:$total_use_tm"
}

main
