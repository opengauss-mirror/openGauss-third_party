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
# build and install component
#######################################################################
function copyToOutput()
{
   OUT_PUT_DIR="${TOP_DIR}/output/dependency/$PLAT_FORM_STR/pljava"
   if [ ! -d "${OUT_PUT_DIR}" ]; then
   mkdir $OUT_PUT_DIR -p 
   fi
   mkdir "$OUT_PUT_DIR/llt/java" -p
   mkdir "$OUT_PUT_DIR/llt/lib" -p
   mkdir "$OUT_PUT_DIR/comm/java" -p
   mkdir "$OUT_PUT_DIR/comm/lib" -p
   PLJAVA_ROOT_DIR=${TOP_DIR}/dependency/pljava
   cp ${PLJAVA_ROOT_DIR}/pljava-1_5_2/pljava/target/pljava.jar $OUT_PUT_DIR/llt/java
   cp ${PLJAVA_ROOT_DIR}/pljava-1_5_2/pljava/target/pljava.jar $OUT_PUT_DIR/comm/java
   cp ${PLJAVA_ROOT_DIR}/pljava-1_5_2/pljava-so/target/libpljava.so $OUT_PUT_DIR/llt/lib
   cp ${PLJAVA_ROOT_DIR}/pljava-1_5_2/pljava-so/target/libpljava.so $OUT_PUT_DIR/comm/lib
   cp ${PLJAVA_ROOT_DIR}/pljava-1_5_2/udstools.py $OUT_PUT_DIR/llt/
   cp ${PLJAVA_ROOT_DIR}/pljava-1_5_2/udstools.py $OUT_PUT_DIR/comm/

}
function build_component()
{
    cd ${LOCAL_DIR}
    [ -n "${ICE_SOURCE_CODE_PATH}" ] && rm -rf ${ICE_SOURCE_CODE_PATH}
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf ${SOURCE_CODE_PATH}
    [ -n "${SOURCE_CODE_PATH}.log" ] && rm -rf ${SOURCE_CODE_PATH}.log
    unzip ${ZIP_FILE_NAME}
    tar -xf ${ICE_SOURCE_CODE_PATH}/${TAR_FILE_NAME}
    patch -p0 < huawei_pljava.patch 2>&1
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    log "[Notice] pljava start configure"

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] pljava not supported build type."
                ;;
            debug)
                die "[Error] pljava not supported build type."
                ;;
            comm)
                cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
                make -sj pljava
                make -sj all
                ;;
            release_llt)
                die "[Error] pljava not supported build type."
                ;;
            debug_llt)
                die "[Error] pljava not supported build type."
                ;;
            llt)
                cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
                make -sj pljava
                make -sj all
                ;;
             *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
        esac

        if [ $? -ne 0 ]; then
                die "[Error] pljava configure failed."
        fi
        log "[Notice] pljava End configure"

        log "[Notice] pljava using \"${COMPILE_TYPE}\" Begin make"
        make
        if [ $? -ne 0 ]; then
                die "pljava make failed."
        fi
        log "[Notice] pljava End make"

        log "[Notice] pljava using \"${COMPILE_TYPE}\" Begin make install"
        if [ $? -ne 0 ]; then
                die "pljava make install failed."
        fi
        log "[Notice] pljava End make install"
    done
}
#######################################################################
# clean component
#######################################################################
function clean_component()
{
    cd ${LOCAL_DIR}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR} failed."
    fi
    [ -n "install_comm_dist" ] && rm -rf "install_comm_dist"
    [ -n "install_llt_dist" ] && rm -rf "install_llt_dist"
    [ -n "${ICE_SOURCE_CODE_PATH}" ] && rm -rf ${ICE_SOURCE_CODE_PATH}
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf ${SOURCE_CODE_PATH}
    [ -n "${SOURCE_CODE_PATH}.log" ] && rm -rf ${SOURCE_CODE_PATH}.log
    [ -n "tmp_id.dat" ] && rm -rf "tmp_id.dat"
    log "[Notice] pljava clean has been finished!"
}
