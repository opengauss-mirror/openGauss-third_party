#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install platform
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
export BUILD_TOOLS_PATH=${BUILD_SCRIPT_PATH}/../../buildtools

. ${BUILD_SCRIPT_PATH}/../../build/common.sh

function export_gcc() {
    export CC=${BUILD_TOOLS_PATH}/gcc/install_comm/bin/gcc
    export CXX=${BUILD_TOOLS_PATH}/gcc/install_comm/bin/g++
    export LD_LIBRARY_PATH=${BUILD_TOOLS_PATH}/gcc/install_comm/lib64:${BUILD_TOOLS_PATH}/mpc/install_comm/lib:${BUILD_TOOLS_PATH}/mpfr/install_comm/lib:${BUILD_TOOLS_PATH}/gmp/install_comm/lib:${BUILD_TOOLS_PATH}/isl/install_comm/lib
    export PATH=${BUILD_TOOLS_PATH}/gcc/install_comm/bin:$PATH
}

function build_first() {
    build_item securec
}

function main() {
    cd $BUILD_SCRIPT_PATH
    rm -rf *.log
    total_start_tm=$(date +%s%N)
    export_gcc
    build_first
    total_end_tm=$(date +%s%N)
    total_use_tm=$(echo $total_end_tm $total_start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
    echo "total time:$total_use_tm"
}

main
