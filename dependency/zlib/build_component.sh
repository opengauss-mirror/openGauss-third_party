#!/bin/bash
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
#  description: the script that make install zlib
#  date: 2015-8-20
#  version: 1.0
#  history:
#    2015-12-19 update to zlib1.2.8
#    2017-04-21 update to zlib1.2.11

#######################################################################
# build and install component
#######################################################################
set -e

WORK_PATH="$(dirname $0)"

source "${WORK_PATH}/build_component_configure.sh"

function build_component()
{
    cd ${LOCAL_DIR}
    tar -xvf ${TAR_FILE_NAME}
    
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    chmod +x configure        
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        log "[Notice] zlib Begin configure..."

        build_component_configure
 
        if [ $? -ne 0 ]; then
            die "zlib make failed."
        fi
        log "[Notice] zlib End make" 

        log "[Notice] zlib using \"${COMPILE_TYPE}\" Begin make install" 
        make install
        if [ $? -ne 0 ]; then
                    die "[Error] zlib make install failed."
                fi
        log "[Notice] zlib using \"${COMPILE_TYPE}\" End make install" 

        ######### make libminiunz ########
        log "[Notice] make and install libminiunz before zlib clean " 
        log "[Notice] copying makefile and patches" 
        cp ../Makefile.miniunz contrib/minizip/
        cp ../huawei_unzip_alloc_hook.patch  contrib/minizip/
        cp ../huawei_unzip_alloc_hook.patch2 contrib/minizip/

        log "[Notice] enter contrib/minizip/" 
        cd contrib/minizip/

        case "${COMPILE_TYPE}" in
            comm)
                log "[Notice] patching unzip.h" 
                patch unzip.h huawei_unzip_alloc_hook.patch2
                if [ $? -ne 0 ]; then
                    die "failed to patch unzip.h for memory hook."
                fi

                log "[Notice] patching unzip.c" 
                patch unzip.c huawei_unzip_alloc_hook.patch
                if [ $? -ne 0 ]; then
                    die "failed to patch unzip.c for memory hook."
                fi
                ;;
            llt)
                ;;
        esac

        log "[Notice] make libminiunz" 
        make -f Makefile.miniunz
        if [ $? -ne 0 ]; then
            die "failed to make libminiunz."
        fi

        ######### make install libminiunz ########
        log "[Notice] make install libminiunz" 
        make install -f Makefile.miniunz DESTDIR=${LOCAL_DIR}/install_${COMPILE_TYPE}
        if [ $? -ne 0 ]; then
            die "[Error] libminiunz make install failed."
        fi

        ######### make install libminiunz ########
        log "[Notice] make clean libminiunz" 
        make clean -f Makefile.miniunz
        log "[Notice] exit contrib/minizip/" 
        cd ../..

        make clean
        log "[Notice] zlib build using \"${COMPILE_TYPE}\" has been finished" 
    done    
}
