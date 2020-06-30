#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install all of binarylibs
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

function logerr() {
    echo "[ERROR] $@" 1>&2
}

function logwarn() {
    echo "[WARNING] $@" 1>&2
}

function check_ret() {
    if [ $? -ne 0 ]; then
        logerr "$@"
        exit 1
    fi
}

function loginfo() {
    echo "[INFO] $@" 1>&2
}

function date_str() {
    printf "$(date +'%Y-%m-%d %H:%M:%S')"
}

function logbuild() {
    length_of_line=30
    printf "[BUILD] $1 "
    for ((i = ${#1}; i < $length_of_line; i++)); do
        printf '.'
    done
    printf " "
}

function build_item() {
    item=${1}
    errexit_old_val=$(set -o | grep errexit | awk '{print $2}')
    set +e
    logbuild ${1}
    start_tm=$(date +%s%N)
    cd ${OPEN_SOURCE}/${item}/build
    sh build_${item}.sh > $BUILD_SCRIPT_PATH/${1}_build.log 2>&1
    build_result=$?
    end_tm=$(date +%s%N)
    use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")

    if [ $build_result -eq 0 ]; then
        printf "OK [%7ss]\n" "${use_tm}"
    else
        printf "FAILED [%7ss]\n" "${use_tm}"
        exit 1
    fi
    if [ $errexit_old_val == "on" ]; then
        set -e
    fi
}

function main() {
    cd $BUILD_SCRIPT_PATH
    if [ ! -f "$BUILD_SCRIPT_PATH/../buildtools/gcc/gcc-8.2.0.tar.gz" ] \
         && [ ! -f "$BUILD_SCRIPT_PATH/../buildtools/gcc/gcc-8.2.0.zip" ]; then
        echo "[ERROR]: You should download gcc-8.2.0.tar.gz or gcc-8.2.0.zip and put it in $BUILD_SCRIPT_PATH/../buildtools/gcc/"
        exit 1
    fi
    rm -rf *.log
    total_start_tm=$(date +%s%N)
    build_item buildtools
    build_item dependency
    build_item platform
    total_end_tm=$(date +%s%N)
    total_use_tm=$(echo $total_end_tm $total_start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
    echo "total time:$total_use_tm"
}
main
