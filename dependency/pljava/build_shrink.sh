#!/bin/bash
# Perform PL/Java lib installation.
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
#  description: the script that make install pljava libs
#  date: 2019-5-16
#  modified: 
#  version: 1.0
#  history:
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
                mkdir -p ${LOCAL_DIR}/install_comm_dist/lib
                cp ${LOCAL_DIR}/pljava-1_5_2/lib/*  ${LOCAL_DIR}/install_comm_dist/lib -r
                mkdir -p ${LOCAL_DIR}/install_comm_dist/java
                cp ${LOCAL_DIR}/pljava-1_5_2/pljava/target/pljava.jar  ${LOCAL_DIR}/install_comm_dist/java -r
               # echo ${LOCAL_DIR}/pljava-1_5_2/pljava/target/pljava.jar
                cp ${LOCAL_DIR}/pljava-1_5_2/udstools.py  ${LOCAL_DIR}/install_comm_dist/ -r
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/lib/* ${LOCAL_DIR}/install_comm_dist\" failed."
                fi
                ;;
            release)
                ;;
            debug)
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt_dist/lib
                cp ${LOCAL_DIR}/pljava-1_5_2/lib/*  ${LOCAL_DIR}/install_llt_dist/lib -r
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r {LOCAL_DIR}/pljava-1_5_2/lib/* ${LOCAL_DIR}/install_llt_dist/lib\" failed."
                fi
                mkdir -p ${LOCAL_DIR}/install_llt_dist/java
                cp ${LOCAL_DIR}/pljava-1_5_2/pljava/target/pljava.jar  ${LOCAL_DIR}/install_llt_dist/java -r
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/pljava-1_5_2/pljava/target/pljava.jar ${LOCAL_DIR}/install_llt_dist/java\" failed."
                fi
                cp ${LOCAL_DIR}/pljava-1_5_2/udstools.py  ${LOCAL_DIR}/install_llt_dist/ -r
                if [ $? -ne 0 ]; then
                    die "[Error] \"cp -r ${LOCAL_DIR}/pljava-1_5_2/udstools.py ${LOCAL_DIR}/install_llt_dist/\" failed."
                fi
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
                [ -n "${INSTALL_COMPONENT_PATH_NAME}/comm/" ] && rm -rf ${INSTALL_COMPONENT_PATH_NAME}/comm/*
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
                [ -n "${INSTALL_COMPONENT_PATH_NAME}/llt/" ] && rm -rf ${INSTALL_COMPONENT_PATH_NAME}/llt/*
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
        log "[Notice] pljava dist using \"${COMPILE_TYPE}\" has been finished!"
    done
}
