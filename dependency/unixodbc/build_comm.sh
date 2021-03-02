#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2019. All rights reserved.
# description: the script that make install unixODBC
# date: 2019-12-28
# version: 1.1
# history:

WORK_PATH="$(dirname ${0})"
source "${WORK_PATH}/build_global.sh"

#######################################################################
# build and install component
#######################################################################
function build_component()
{
    cd ${LOCAL_DIR}
    tar -xvf ${TAR_FILE_NAME}
 
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi

    tmp_cpus=$(grep -w processor /proc/cpuinfo|wc -l)
    
    log "[Notice] Start autoreconf."
    autoreconf -fi
    if [ $? -ne 0 ]; then
	die "[Error] autoreconf failed, please install libtool and libtool-ltdl-devel."
    fi

    chmod +x configure       
    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] unixODBC not supported build type."
                ;;
            debug)
                die "[Error] unixODBC not supported build type."
                ;;
            comm)    
                mkdir -p ${LOCAL_DIR}/install_comm/unixODBC-2.3.9
                mkdir -p ${LOCAL_DIR}/install_comm/unixODBC-2.3.9/etc
                log "[Notice] unixODBC configure string: ./configure --enable-gui=no --prefix=${LOCAL_DIR}/install_comm"
                ./configure CFLAGS='-fstack-protector-all -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fPIC -fPIE -pie' --enable-gui=no --prefix=${LOCAL_DIR}/install_comm/unixODBC-2.3.9 ${BUILD_TYPE_OPTION}
                ;;
            release_llt)
                die "[Error] unixODBC not supported build type."
                ;;
            debug_llt)
                die "[Error] unixODBC not supported build type."
                ;;
            llt)
                die "[Error] unixODBC not supported build type."
                ;;
            *)
                log "Internal Error: option processing error: $1"   
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
        esac

        if [ $? -ne 0 ]; then
            die "[Error] unixODBC configure failed."
        fi
        log "[Notice] unixODBC End configure"

      
	log "[Notice] disable rpath"

	sed -i 's/runpath_var=LD_RUN_PATH/runpath_var=""/g' ./libtool
	sed -i 's/hardcode_libdir_flag_spec="\\\${wl}-rpath \\\${wl}\\\$libdir"/hardcode_libdir_flag_spec=""/g' ./libtool

	PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)

        if [ "${PLAT_FORM_STR}"X = "euleros2.0_sp8_aarch64"X ]
        then
                sed -i "385c hardcode_libdir_flag_spec=" libtool
        fi


        log "[Notice] unixODBC using \"${COMPILE_TYPE}\" Begin make"
        make -j${tmp_cpus}
        if [ $? -ne 0 ]; then
            die "unixODBC make failed."
         fi
        log "[Notice] unixODBC End make"
      
        log "[Notice] unixODBC using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
            die "[Error] unixODBC make install failed."
        fi
        log "[Notice] unixODBC using \"${COMPILE_TYPE}\" End make install"
        sed -i '399i#ifndef PACKAGE_BUGREPORT' ${LOCAL_DIR}/install_comm/unixODBC-2.3.9/include/unixodbc_conf.h
        sed -i '417i#endif' ${LOCAL_DIR}/install_comm/unixODBC-2.3.9/include/unixodbc_conf.h 
        make clean
        log "[Notice] unixODBC build using \"${COMPILE_TYPE}\" has been finished"

    done
}

#######################################################################
# clean component 
#######################################################################
function clean_component()
{
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR}/${SOURCE_CODE_PATH} failed."
    fi

    cd ${LOCAL_DIR}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR} failed."
    fi
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf ${SOURCE_CODE_PATH}
    rm -rf install_*

    log "[Notice] unixODBC clean has been finished!"
}
