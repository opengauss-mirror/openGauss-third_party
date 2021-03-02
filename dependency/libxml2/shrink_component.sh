#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install libxml2
# date: 2020-06-24
# version: 1.2
# history: 2020-06-24 fix buildcheck warning

set -e

#######################################################################
# choose the real files 
#######################################################################
function shrink_component()
{
    rm -rf ${LOCAL_DIR}/install_comm_dist
    rm -rf ${LOCAL_DIR}/install_llt_dist
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                rm -f ${LOCAL_DIR}/install_comm_dist/lib/*so*
                ;;
            release)
                ;;
            debug)
                ;;
            llt)
                mkdir ${LOCAL_DIR}/install_llt_dist
                cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist
                if [ $? -ne 0 ]; then 
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist\" failed."
                fi
                rm -f ${LOCAL_DIR}/install_llt_dist/lib/*so*
                mv ${LOCAL_DIR}/install_llt_dist/lib/libxml2.a ${LOCAL_DIR}/install_llt_dist/lib/libxml2_pic.a    
                ;;
            release_llt)
                ;;
            debug_llt)
                ;;
            *)
        esac
        log "[Notice] libxml2 shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}
