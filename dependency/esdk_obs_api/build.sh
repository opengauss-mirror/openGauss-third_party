#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install libcurl
# date: 2020-11-16
# version: 3.19.9.3
# history:
# 2020-04-11 upgrade to 3.19.9.3
set -e
python $(pwd)/../../build/pull_open_source.py "esdk_obs_api" "huaweicloud-sdk-c-obs-3.19.9.3.tar.gz" "05834LGL"

TAR_FILE=${PWD}/huaweicloud-sdk-c-obs-3.19.9.3.tar.gz
SRC_DIR=${PWD}/huaweicloud-sdk-c-obs-3.19.9.3
ARCH=`uname -m`

TRUNK_DIR=${PWD}/../../
THIRD_PARTY_BINARYLIBS=$THIRDPARTY_FOLDER

PLATFORM=$(bash ${TRUNK_DIR}/build/get_PlatForm_str.sh)

INSTALL_DIR="$TRUNK_DIR/output/dependency/$PLATFORM/libobs/comm/"
PREFIX_DIR="$TRUNK_DIR/dependency/esdk_obs_api"
LOG_FILE="$TRUNK_DIR/dependency/esdk_obs_api/libobs.log"


#######################################################################
#  Print log.
#######################################################################
log()
{
    printf "[Build libobs] $(date +%y-%m-%d): $@"
    echo "[Build libobs] $(date +%y-%m-%d): $@" >> "$LOG_FILE" 2>&1
}

print_done()
{
    echo "done"
}

#######################################################################
#  print log and exit.
#######################################################################
die()
{
    log "$@"
    echo "$@"
    echo "For more information, please see the log file: $LOG_FILE"
    exit $BUILD_FAILED
}

checkret()
{
    if [ $? -ne 0 ]
    then
        die "[Error] " $1
    fi
}

main()
{
    rm -f $LOG_FILE;
    tar -xf $TAR_FILE
    checkret "Failed to unpackage the tar file: $TAR_FILE"

    cd ${SRC_DIR}
    log "[Info] patching ......... "
    patch -p1 < ../huawei_obs.patch >> $LOG_FILE 2>&1
    sed -i '123c make -j16' ./source/eSDK_OBS_API/eSDK_OBS_API_C++/build.sh
    sed -i '128c make -j16' ./source/eSDK_OBS_API/eSDK_OBS_API_C++/build.sh
    checkret "Failed to patch huawei_obs.patch"
    print_done

    cd ${SRC_DIR}/source/eSDK_OBS_API/eSDK_OBS_API_C++/
    sh build.sh obs>> $LOG_FILE 2>&1
    checkret "Failed to make install."
    print_done
    
    
    log "[Info] Successfully installed libobs into $INSTALL_DIR"
    echo "copying lib..."
    mkdir -p ${INSTALL_DIR}/lib
    mkdir -p ${INSTALL_DIR}/include
    # copy securec lib to libos
    #cp ${SRC_DIR}/platform/huaweisecurec/include/* ${INSTALL_DIR}/include/
    #cp ${SRC_DIR}/platform/huaweisecurec/lib/* ${INSTALL_DIR}/lib/
    # copy liblog4cpp to libobs
    if [ $ARCH = "aarch64" ];then
        cp ${SRC_DIR}/platform/eSDK_LogAPI_V2.1.10/C/aarch64/libeSDKLogAPI.so ${INSTALL_DIR}/lib/
    else
        cp ${SRC_DIR}/platform/eSDK_LogAPI_V2.1.10/C/linux_64/libeSDKLogAPI.so ${INSTALL_DIR}/lib/
    fi
    cp ${SRC_DIR}/platform/eSDK_LogAPI_V2.1.10/log4cpp/build/lib/liblog4cpp.so ${INSTALL_DIR}/lib/
    cp ${SRC_DIR}/platform/eSDK_LogAPI_V2.1.10/log4cpp/build/lib/liblog4cpp.so.5 ${INSTALL_DIR}/lib/
    cp ${SRC_DIR}/platform/eSDK_LogAPI_V2.1.10/log4cpp/build/lib/liblog4cpp.so.5.0.6 ${INSTALL_DIR}/lib/
    # copy pcre lib to libobs
    cp ${TRUNK_DIR}/dependency/pcre/install_comm/lib/libpcre.so ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/pcre/install_comm/lib/libpcre.so.1 ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/pcre/install_comm/lib/libpcre.so.1.2.12 ${INSTALL_DIR}/lib/
    # copy libiconv lib to libobs
    cp ${TRUNK_DIR}/dependency/libiconv/install_comm/lib/libcharset.so ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/libiconv/install_comm/lib/libcharset.so.1 ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/libiconv/install_comm/lib/libcharset.so.1.0.0 ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/libiconv/install_comm/lib/libiconv.so ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/libiconv/install_comm/lib/libiconv.so.2 ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/libiconv/install_comm/lib/libiconv.so.2.6.1 ${INSTALL_DIR}/lib/
    #cp ${TRUNK_DIR}/dependency/libiconv/install_comm/lib/preloadable_libiconv.so ${INSTALL_DIR}/lib/
    # copy nghttp2 lib to libobs
    cp ${TRUNK_DIR}/dependency/nghttp2/install_comm/lib/libnghttp2.so ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/nghttp2/install_comm/lib/libnghttp2.so.14 ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/nghttp2/install_comm/lib/libnghttp2.so.14.20.0 ${INSTALL_DIR}/lib/
    # copy libxml2 lib to libobs
    cp ${TRUNK_DIR}/dependency/libxml2/install_comm/lib/libxml2.so ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/libxml2/install_comm/lib/libxml2.so.2 ${INSTALL_DIR}/lib/
    cp ${TRUNK_DIR}/dependency/libxml2/install_comm/lib/libxml2.so.2.9.9 ${INSTALL_DIR}/lib/
    # copy libobs to install dir
    cd ${SRC_DIR}/source/eSDK_OBS_API/eSDK_OBS_API_C++
    cp OBS.ini ${INSTALL_DIR}/lib/
    cd ./build
    cp ./include/eSDKOBS.h ${INSTALL_DIR}/include/
    cp ./lib/libeSDKOBS.so ${INSTALL_DIR}/lib/
}

if [ x"$PLATFORM" = x"" ] || [ "$PLATFORM" = "Failed" ] 
then
    die "[Error] Failed to get platform string, please check ${TRUNK_DIR}/Code/src/get_PlatForm_str.sh"
fi

main
