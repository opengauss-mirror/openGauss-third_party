#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install libcurl
# date: 2020-11-16
# version: 7.71.0
# history:
# 2020-11-16 upgrade to curl-7.71.0.tar.gz

set -e
python $(pwd)/../../build/pull_open_source.py "libcurl" "curl-7.71.1.tar.gz" "05836PYW"

tmp_cpus=$(grep -w processor /proc/cpuinfo|wc -l)

TAR_FILE=curl-7.71.1.tar.gz
SRC_DIR=curl-7.71.1

TRUNK_DIR=${PWD}/../../
THIRD_PARTY_BINARYLIBS=$THIRDPARTY_FOLDER

PLATFORM=$(bash ${TRUNK_DIR}/build/get_PlatForm_str.sh)

INSTALL_DIR="$TRUNK_DIR/output/dependency/$PLATFORM/libcurl/comm/"
INSTALL_DIR_LLT="$TRUNK_DIR/output/dependency/$PLATFORM/libcurl/llt/"
PREFIX_DIR="$TRUNK_DIR/dependency/libcurl/curl"
LOG_FILE="$TRUNK_DIR/dependency/libcurl/libcurl.log"

#######################################################################
#  Print log.
#######################################################################
log()
{
    printf "[Build libcurl] $(date +%y-%m-%d" "%T): $@"
    echo "[Build libcurl] $(date +%y-%m-%d" "%T): $@" >> "$LOG_FILE" 2>&1
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
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TRUNK_DIR/output/dependency/$PLATFORM/openssl/comm/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TRUNK_DIR/output/dependency/$PLATFORM/zlib1.2.11/comm/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TRUNK_DIR/output/dependency/$PLATFORM/kerberos/comm/lib
    export C_INCLUDE_PATH=$C_INCLUDE_PATH:$TRUNK_DIR/output/dependency/$PLATFORM/kerberos/comm/include

    #set_gcc
    rm -rf SRC_DIR
    tar -xf $TAR_FILE
    checkret "Failed to unpackage the tar file: $TAR_FILE"

    cd $SRC_DIR

    log "[Info] patching ......... "
    patch -p1 < ../huawei_curl.patch >> $LOG_FILE 2>&1
    checkret "Failed to patch huawei_curl.patch"
    patch -p1 < ../CVE-2020-8231.patch >> $LOG_FILE 2>&1
    checkret "Failed to patch CVE-2020-8231.patch"
    patch -p1 < ../CVE-2020-8284.patch >> $LOG_FILE 2>&1
    checkret "Failed to patch CVE-2020-8284.patch"
    patch -p1 < ../CVE-2020-8285.patch >> $LOG_FILE 2>&1
    checkret "Failed to patch CVE-2020-8285.patch"
    patch -p1 < ../CVE-2020-8286.patch >> $LOG_FILE 2>&1
    checkret "Failed to patch CVE-2020-8286.patch"
    print_done

    chmod a+x configure

    log "[Info] configuring ...... "
    ./configure --prefix="$PREFIX_DIR" --with-ssl=$TRUNK_DIR/output/dependency/$PLATFORM/openssl/comm --without-libssh2 CFLAGS='-fstack-protector-strong -Wl,-z,relro,-z,now' --with-zlib=$TRUNK_DIR/output/dependency/$PLATFORM/zlib1.2.11/comm --with-gssapi_krb5_gauss-includes=$TRUNK_DIR/output/dependency/$PLATFORM/kerberos/comm/include --with-gssapi_krb5_gauss-libs=$TRUNK_DIR/output/dependency/$PLATFORM/kerberos/comm/lib  >> $LOG_FILE 2>&1
    checkret "Failed to configure libcurl."
    print_done
    
    log "[Info] making ... "
    make -j${tmp_cpus}   >> $LOG_FILE 2>&1
    log "[Info] making install ... "
    make install   >> $LOG_FILE 2>&1
    checkret "Failed to make install."
    print_done
   
    mkdir -p $INSTALL_DIR 
    cp -Lr $PREFIX_DIR/lib $INSTALL_DIR
    cp -r $PREFIX_DIR/include $INSTALL_DIR
    cd $INSTALL_DIR/lib
    rm -rf pkgconfig/
    rm libcurl.a libcurl.la
    cp -r $INSTALL_DIR $INSTALL_DIR_LLT
    
    log "[Info] Successfully installed libcurl into $INSTALL_DIR"
    echo ""
}

if [ x"$PLATFORM" = x"" ] || [ "$PLATFORM" = "Failed" ] 
then
    die "[Error] Failed to get platform string, please check ${TRUNK_DIR}/build/get_PlatForm_str.sh"
fi

main
