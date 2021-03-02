#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2019. All rights reserved.
# description: the script that make install unixODBC
# date: 2019-12-28
# version: 1.1
# history:

WORK_PATH="$(dirname ${0})"
source "${WORK_PATH}/build_global.sh"

#######################################################################
# choose the real files 
#######################################################################
function shrink_component()
{
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir ${LOCAL_DIR}/install_comm_dist
                cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist
                if [ $? -ne 0 ]; then
                     die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            release)
                ;;
            debug)
                ;;
            llt)
                ;;
            release_llt)
                ;;
            debug_llt)
                ;;
            *)
        esac
        log "[Notice] unixODBC shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
#    we could makesure that $INSTALL_COMPOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component()
{
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        case "${COMPILE_TYPE}" in
            comm)
                mkdir -p ${INSTALL_COMPOENT_PATH_NAME}
                rm -rf ${INSTALL_COMPOENT_PATH_NAME}/*
                cp -r ${LOCAL_DIR}/install_comm_dist/unixODBC-2.3.9/* ${INSTALL_COMPOENT_PATH_NAME}
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPOENT_PATH_NAME}/comm\" failed."
                fi 
                ;;
            release)
                ;;
            debug)
                ;;
            llt)
                ;;
            release_llt)
                ;;
            debug_llt)
                ;;
            *)
        esac
        log "[Notice] unixODBC dist using \"${COMPILE_TYPE}\" has been finished!"
    done
}
