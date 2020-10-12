#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script is common functions
#  date: 2020-06-01
#  version: 1.0
#  history:
#
# *************************************************************************
function check_requirements() {
    local_dir_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    result="True"
    lines=$(cat ${local_dir_path}/requirements.txt | awk '{print $0}')
    for line in ${lines}
    do
        query_result=$(rpm -qa | grep -c ${line})
        if [ $? -ne 0 ]; then
            echo "[Notice]:${line} should be installed."
            result="False"
        fi
    done
    python_version=`python -V 2>&1 | awk '{print $2}' | awk -F '.' '{print $1}'`
    if [ "${python_version}" != "3" ]; then
        echo "[Notice]:We need default Python version is 3.x"
        result="False"
    fi

    if [ "${result}" == "False" ]; then
        exit 1
    fi
}

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
    check_requirements
    cd ${OPEN_SOURCE}
    errexit_old_val=$(set -o | grep errexit | awk '{print $2}')
    set +e
    logbuild $1
    cd $1
    start_tm=$(date +%s%N)
    grep "build_option" build.sh > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        #bash build.sh -m clean
        bash build.sh -m all > $BUILD_SCRIPT_PATH/${1}_build.log 2>&1
        build_result=$?
    else
        bash build.sh > $BUILD_SCRIPT_PATH/${1}_build.log 2>&1
        build_result=$?
    fi
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