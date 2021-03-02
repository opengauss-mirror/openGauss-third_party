#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2022. All rights reserved.
# description: the script that make install cjson
# date: 2020-08-10
# version: 2.0
# history:
# 2019-5-5 update to cjson 1.7.11 from 1.7.7
# 2019-12-28 fix buildcheck warning
# 2020-06-22 fix buildcheck warning
# 2020-08-10 update to cjson 1.7.13 from 1.7.11

set -e

#######################################################################
# build and install component
#######################################################################
function build_component()
{
    cd ${LOCAL_DIR}
    tar -xvf ${TAR_FILE_NAME}

    patch -p0 < huawei_cJSON-1.7.13.patch

    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
                die "[Error] change dir to $SRC_DIR failed."
    fi

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] cjson not supported build type."
                ;;
            debug)
                die "[Error] cjson not supported build type."
                ;;
            release_llt)
                die "[Error] cjson not supported build type."
                ;;
            debug_llt)
                die "[Error] cjson not supported build type."
                ;;
            comm|llt)
                mkdir -p ${LOCAL_DIR}/install_${COMPILE_TYPE}
                log "[Notice] cjson using \"${COMPILE_TYPE}\" Begin make"
                
                make
                ;;
            *)
                log "Internal Error: option processing error: $1"   
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
        esac
 
        if [ $? -ne 0 ]; then
            die "cjson make failed."
        fi
        log "[Notice] cjson End make" 

        log "[Notice] cjson using \"${COMPILE_TYPE}\" Begin make install" 
        make install PREFIX=${LOCAL_DIR}/install_${COMPILE_TYPE}
        if [ $? -ne 0 ]; then
           die "[Error] cjson make install failed."
        fi
        log "[Notice] cjson using \"${COMPILE_TYPE}\" End make install" 
        make clean -s
        log "[Notice] cjson build using \"${COMPILE_TYPE}\" has been finished" 
    done    
}
