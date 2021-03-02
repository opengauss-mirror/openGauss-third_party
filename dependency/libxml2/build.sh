#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install libxml2
# date: 2020-06-24
# version: 1.2
# history: 2019-12-17 fix buildcheck warning
# history: 2020-06-24 fix buildcheck warning

set -e
python $(pwd)/../../build/pull_open_source.py "libxml2" "libxml2-2.9.9.tar.gz" "05833DFT"

WORK_PATH="$(dirname $0)"

source "${WORK_PATH}/build_common.sh"

source "${WORK_PATH}/build_component.sh"

source "${WORK_PATH}/shrink_component.sh"

source "${WORK_PATH}/dist_component.sh"

source "${WORK_PATH}/clean_component.sh"

function main()
{
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
            clean_component
            ;;
        *)
            log "Internal Error: option processing error: $2"   
            log "please input right paramenter values build, shrink, dist or clean "
    esac
}


########################################################################
if [ $# = 0 ] ; then
    log "missing option"
    print_help
    exit 1
fi

##########################################################################
#read command line paramenters
##########################################################################
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            print_help
            exit 1
            ;;
        -m|--build_option)
            if [ "$2"X = X ];then
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
    esac
done

###########################################################################
main
