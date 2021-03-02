#!/bin/bash
# Perform PL/Java lib installation.
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install pljava libs
# date: 2019-5-16
# modified:
# version: 1.0
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
                mkdir -p ${LOCAL_DIR}/install_comm_dist
		mkdir -p ${LOCAL_DIR}/install_comm_dist/bin
                cp ${LOCAL_DIR}/install_comm/include  ${LOCAL_DIR}/install_comm_dist/ -r
                cp ${LOCAL_DIR}/install_comm/lib  ${LOCAL_DIR}/install_comm_dist/ -r
                cp ${LOCAL_DIR}/install_comm/bin/llvm-config  ${LOCAL_DIR}/install_comm_dist/bin/ 
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
		rm -rf ${LOCAL_DIR}/install_comm_dist/lib/*so*
            ;;
            release)
            ;;
            debug)
            ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist
		mkdir -p ${LOCAL_DIR}/install_llt_dist/bin
                cp ${LOCAL_DIR}/install_llt/include ${LOCAL_DIR}/install_llt_dist/ -r
                cp ${LOCAL_DIR}/install_llt/lib ${LOCAL_DIR}/install_llt_dist/ -r
                cp ${LOCAL_DIR}/install_llt/bin/llvm-config ${LOCAL_DIR}/install_llt_dist/bin/ 
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_llt/* ${LOCAL_DIR}/install_llt_dist\" failed."
                fi
		rm -rf ${LOCAL_DIR}/install_llt_dist/lib/*so*
            ;;
            release_llt)
            ;;
            debug_llt)
            ;;
            *)
        esac
        log "[Notice] libtinfo shrink using \"${COMPILE_TYPE}\" has been finished!"
    done
}

##############################################################################################################
# dist the real files to the matched path
# we could makesure that $INSTALL_COMPNOENT_PATH_NAME is not null, '.' or '/'
##############################################################################################################
function dist_component()
{
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        case "${COMPILE_TYPE}" in
            comm)
                rm -rf ${INSTALL_COMPONENT_PATH_NAME}/comm/*
                mkdir -p ${INSTALL_COMPONENT_PATH_NAME}
                mkdir -p ${INSTALL_COMPONENT_PATH_NAME}/comm
                cp -r ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPONENT_PATH_NAME}/comm
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPONENT_PATH_NAME}/comm\" failed."
                fi
            ;;
            release)
            ;;
            debug)
            ;;
            llt)
                rm -rf ${INSTALL_COMPONENT_PATH_NAME}/llt/*
                mkdir -p ${INSTALL_COMPONENT_PATH_NAME}/llt
                cp -r ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPONENT_PATH_NAME}/llt
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPONENT_PATH_NAME}/llt\" failed."
                fi
            ;;
            release_llt)
            ;;
            debug_llt)
            ;;
            *)
        esac
        log "[Notice] llvm dist using \"${COMPILE_TYPE}\" has been finished!"
    done
}

