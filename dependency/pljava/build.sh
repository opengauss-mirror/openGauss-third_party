#!/bin/bash
# Perform PL/Java lib installation.
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
#  description: the script that make install pljava libs
#  date: 2019-5-16
#  modified: 
#  version: 1.0
#  history:
WORK_PATH="$(dirname $0)"
source "${WORK_PATH}/build_global.sh"
source "${WORK_PATH}/build_component.sh"
source "${WORK_PATH}/build_shrink.sh"
source "${WORK_PATH}/build_so.sh"
#######################################################################
# main
#######################################################################
function main()
{
    if [ ! -f "${WORK_PATH}/pljava_1.5.2_src.zip" ]; then
    python ${TOP_DIR}/build/pull_open_source.py "pljava" "pljava_1.5.2_src.zip" "05833GUV"
    fi
    case "${BUILD_OPTION}" in
        build)
            build_component
            copyToOutput
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
        only_so)
            build_dist_so
            ;;
        patch_md5)
            make_patch_md5
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

if [ $? -ne 0 ]; then
    echo "source enviroment paramters failed,please execute configure firstly!"
    exit 1
fi
########################################################################
if [ $# = 0 ] ; then
    log "missing option"
    print_help
    exit 1
fi

##########################################################################
#read command line paramenters
##########################################################################
while getopts "hm:" opt
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
            main
            ;;
        h)
            print_help
            ;;
    esac
done




case $1 in
   -m)
     if [ ! -n "$2" ]; then
        echo "not enough params"
     fi
     BUILD_OPTION=$2
     ;;
   *);;
esac

###########################################################################
