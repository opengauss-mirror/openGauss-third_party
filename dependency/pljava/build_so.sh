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
# make patch md5sum for a new patch, make sure to
# run "diff -ruN old new > huawei_pljava.patch" to create one first
#######################################################################
function make_patch_md5()
{
    md5sum huawei_pljava.patch | cut -d ' ' -f1 >> patch_ids.dat
}
#######################################################################
# Return whether the pljava folder matches the current patch
#######################################################################
function is_match_patch(){
    if [ ! -d "${SOURCE_CODE_PATH}" ] || [ ! -f "tmp_id.dat" ]; then
        return 0
    fi
    last_src_id="$(tail -n 1 patch_ids.dat | cut -d ' ' -f1)"
    last_make_id="$(tail -n 1 tmp_id.dat | cut -d ' ' -f1)"
    if [ "$last_make_id" = "$last_src_id" ]; then
        return 1
    else
        return 0
    fi
}
#######################################################################
# Decompression and do patch
#######################################################################
function do_patch(){
    clean_component
    #unzip ${ZIP_FILE_NAME}
    #tar -zxvf ${ICE_SOURCE_CODE_PATH}/${TAR_FILE_NAME}
    #patch -s -p0 < huawei_pljava.patch 2>&1
    if [ $? -ne 0 ]; then
        die "[Error] do plajva patch failed."
    fi
}
#######################################################################
# build .so and dist
#######################################################################
function build_dist_so()
{
    cd ${LOCAL_DIR}
    # patch
    is_match_patch
    if [ $? -ne 1 ]; then
        do_patch
    fi

    # build
    # log "[Notice] pljava start configure"
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    make pljava_so
    if [ $? -ne 0 ]; then
        die "pljava make failed."
    fi
    # log "[Notice] pljava End make"

    # shark
    mkdir -p ${LOCAL_DIR}/install_comm_dist/lib
    cp ${LOCAL_DIR}/pljava-1_5_2/lib/*  ${LOCAL_DIR}/install_comm_dist/lib -r
    if [ $? -ne 0 ]; then
        die "[Error] \"cp -r ${LOCAL_DIR}/lib/* ${LOCAL_DIR}/install_comm_dist\" failed."
    fi
    mkdir -p ${LOCAL_DIR}/install_llt_dist/lib
    cp ${LOCAL_DIR}/pljava-1_5_2/lib/*  ${LOCAL_DIR}/install_llt_dist/lib -r
    if [ $? -ne 0 ]; then
        die "[Error] \"cp -r ${LOCAL_DIR}/lib/* ${LOCAL_DIR}/install_llt_dist\" failed."
    fi

    # dist
    if [ ! -d "${INSTALL_COMPONENT_PATH_NAME}/comm" ];then
        die "[Error] Not found \"${INSTALL_COMPONENT_PATH_NAME}/comm/java/pljava.jar\". Please git pull. failed."
    else
        cp -r ${LOCAL_DIR}/install_comm_dist/* ${INSTALL_COMPONENT_PATH_NAME}/comm
    fi
    if [ ! -d "${INSTALL_COMPONENT_PATH_NAME}/llt" ];then
        die "[Error] Not found \"${INSTALL_COMPONENT_PATH_NAME}/llt/java/pljava.jar\". Please git pull. failed."
    else
        cp -r ${LOCAL_DIR}/install_llt_dist/* ${INSTALL_COMPONENT_PATH_NAME}/llt
    fi
    if [ $? -ne 0 ]; then
            die "[Error] \"cp pljava.so\" failed."
    fi
    cd ${LOCAL_DIR}
    nowtime="$(date --date='0 days ago' "+%Y-%m-%d %H:%M:%S")"
    make_id="$(tail -n 1 patch_ids.dat)"
    echo "$make_id $nowtime" >> tmp_id.dat
}
