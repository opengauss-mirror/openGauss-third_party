#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install libxml2
# date: 2020-06-24
# version: 1.2
# history: 2020-06-24 fix buildcheck warning

set -e

#######################################################################
# build and install component
#######################################################################
function build_component()
{
    cd ${LOCAL_DIR}
    rm -rf install_* ${SOURCE_CODE_PATH}
    tar -xvf ${TAR_FILE_NAME}
    
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi
    patch -p1 < ../libxml2-05843BKG.patch 
    patch -p1 < ../libxml2-05843CYW.patch
    patch -p1 -R < ../libxml2-05843CXW.patch
    patch -p0 < ../libxml2-05843PLW.patch
    tmp_cpus=$(grep -w processor /proc/cpuinfo|wc -l)
    chmod +x configure        
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        log "[Notice] libxml2 Begin configure..."
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] libxml2 not supported build type."
                ;;
            debug)
                die "[Error] libxml2 not supported build type."
                ;;
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm
                log "[Notice] libxml2 configure string: ./configure --with-zlib=no --with-python=no CFLAGS='-fPIE -O2' --prefix=${LOCAL_DIR}/install_comm"
                ./configure --with-zlib=no --with-python=no  CFLAGS='-fPIC -O2' CPPFLAGS='-fPIC -fstack-protector-all -Wstack-protector -s' LDFLAGS='-Wl,-z,relro,-z,now' --prefix=${LOCAL_DIR}/install_comm            
                ;;
            release_llt)
                die "[Error] libxml2 not supported build type."
                ;;
            debug_llt)
                die "[Error] libxml2 not supported build type."
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt
                log "[Notice] libxml2 configure string: ./configure CFLAGS='-fPIC -pie -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector -s' CPPFLAGS='-fPIC -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector -s' LDFLAGS='-Wl,-z,relro,-z,now' --with-threads --with-zlib=no --with-python=no --prefix=${LOCAL_DIR}/install_llt"
                ./configure CFLAGS='-fPIC -pie -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector -s' CPPFLAGS='-fPIC -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector -s' LDFLAGS='-Wl,-z,relro,-z,now' --with-threads --with-zlib=no --with-python=no --prefix=${LOCAL_DIR}/install_llt
                ;;
            *)
                log "Internal Error: option processing error: $1"   
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
           esac

        if [ $? -ne 0 ]; then
            die "[Error] libxml2 configure failed."
        fi
        log "[Notice] libxml2 End configure"

        log "[Notice] libxml2 using \"${COMPILE_TYPE}\" Begin make"
        make -j${tmp_cpus}
        if [ $? -ne 0 ]; then
            die "libxml2 make failed."
        fi
        log "[Notice] libxml2 End make" 

        log "[Notice] libxml2 using \"${COMPILE_TYPE}\" Begin make install" 
        make install
        if [ $? -ne 0 ]; then
            die "[Error] libxml2 make install failed."
        fi
        log "[Notice] libxml2 using \"${COMPILE_TYPE}\" End make install" 

        make clean
        log "[Notice] libxml2 build using \"${COMPILE_TYPE}\" has been finished" 
    done    
}
