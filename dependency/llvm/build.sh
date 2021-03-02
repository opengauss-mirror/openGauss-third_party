#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2010-2019. All rights reserved.
# description: the script that make install llvm libs
# date: 2015-9-15
# modified: 2019-1-29
# version: 2.0
# history:
# modified:
set -e

# [ -f llvm-10.0.0.src.tar.xz ] && rm -rf llvm-10.0.0.src.tar.xz
[ -f llvm-10.0.0.src.tar ] && rm -rf llvm-10.0.0.src.tar
python $(pwd)/../../build/pull_open_source.py "llvm" "llvm-10.0.0.src.tar.xz" "05835YVM"
WORK_PATH="$(dirname $0)"
source "${WORK_PATH}/build_global.sh"
source "${WORK_PATH}/build_component.sh"
source "${WORK_PATH}/build_shrink.sh"
#######################################################################
# main
#######################################################################

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
while getopts "h:m:t:" opt
do
    case "$opt" in
    m)
        if [[ "$OPTARG"X = ""X ]];then
            die "no given version info"
        fi
        if [[ $# -lt 2 ]];then
            die "not enough params"
        fi
        BUILD_OPTION=$OPTARG
        ;;
    t)
        if [[ "$OPTARG"X != "X86"X ]] && [[ "$OPTARG"X != "AArch64"X ]];then
            die "not correct platform"
        fi
        if [[ $# -lt 2 ]];then
            die "not enough params"
        fi
        BUILD_TARGET=$OPTARG
        ;;
    *)
        log "Internal Error: option processing error: $1" 1>&2
        log "please input right paramtenter, the following command may help you"
        log "./build.sh"
        exit 1
    esac
done

###########################################################################
main
