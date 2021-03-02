#!/bin/bash
# Copyright © Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# Description: bash to build etcd and patch

ZIP_FILE=etcd-3.3.23.zip
SRC_DIR=etcd-3.3.23
TRUNK_DIR="${PWD}/../.."
PLATFORM="$(bash ${TRUNK_DIR}/build/get_PlatForm_str.sh)"
LOG_FILE="etcd.log"
INST_DIR="$TRUNK_DIR/output/dependency/$PLATFORM/etcd/comm"
GOPATH="${PWD}/etcd-3.3.23/"
OP=build

#######################################################################
#  Print log.
#######################################################################
log()
{
    echo "[Build etcd] $(date +%y-%m-%d" "%T): $@"
    echo "[Build etcd] $(date +%y-%m-%d" "%T): $@" >> "$LOG_FILE" 2>&1
}

#######################################################################
#  print log and exit.
#######################################################################
die()
{
    log "$@"
    echo "$@"
    exit 1
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
    python $(pwd)/../../build/pull_open_source.py "etcd" "etcd-3.3.23.zip" "05836KAL"
    rm -f "$LOG_FILE"

    [ -n "${SRC_DIR}" ] && rm -rf $SRC_DIR
    
    log "[Info] unpackaging ......"
    unzip $ZIP_FILE >> "$LOG_FILE" 2>&1 
    checkret "Failed to unpackage the tar file: $ZIP_FILE"
    log "[Info] unpackaging ...... done"

    log "[Info] patching ......... "
    patch -p0 < huawei_etcd_log.patch >> $LOG_FILE 2>&1
    checkret "Failed to patch huawei_etcd_log.patch"
    patch -p0 < huawei_etcd.patch >> $LOG_FILE 2>&1
    checkret "Failed to patch huawei_etcd.patch"
    patch -p0 < huawei_etcd_encrypt.patch >> $LOG_FILE 2>&1 
    checkret "Failed to patch huawei_etcd_encrypt.patch"
    patch -p0 < huawei_etcd_listener.patch >> $LOG_FILE 2>&1
    checkret "Failed to patch huawei_etcd_listener.patch"
    log "[Info] patching ...... done"

	log "[Info] testing golang .. "
    golang=$(go version)
    checkret "Failed to get golang compiler. Please install it first(1.9+)"
    log "[Info] testing golang .. done"
	mkdir -p $SRC_DIR/temp
	
    if [ "$OP" == "client" ] ; then
		patch -p0 < huawei_etcd_client.patch >> $LOG_FILE 2>&1
		checkret "Failed to patch huawei_etcd_client.patch"
		cd $SRC_DIR/etcdclient
		checkret "Failed to cd $SRC_DIR/etcdclient"
		make install
		checkret "Failed to compile and make install etcd client"
		mkdir -p $INST_DIR/lib
		checkret "Failed to mkdir $INST_DIR/lib"
		mkdir -p $INST_DIR/include
		checkret "Failed to mkdir $INST_DIR/include"
		cp -f libclientv3.a $INST_DIR/lib
		checkret "Failed to copy $SRC_DIR/etcdclient/libclientv3.a to $INST_DIR/lib"
		cp -f libclientv3.h $INST_DIR/include
		checkret "Failed to copy $SRC_DIR/etcdclient/libclientv3.h to $INST_DIR/include"
        return 0
    fi


    mkdir -p $GOPATH/vendor/go.etcd.io/etcd/pkg
    ln -s $GOPATH/pkg/fileutil $GOPATH/vendor/go.etcd.io/etcd/pkg/fileutil
	
    cd $SRC_DIR
    
    log "[Info] building ........."
    export ETCD_SETUP_GOPATH=1
    export GO111MODULE=off
    bash ./build >> "$LOG_FILE" 2>&1
    checkret "Failed to make."
    log "[Info] building ......... done"
    
    log "[Info] installing ......."
    mkdir -p "$INST_DIR"
    checkret "Failed to create install dir $INST_DIR"
    log "[Info] init install dir . done"
    
    cp -r bin "$INST_DIR/"
    checkret "Failed to install."
    log "[Info] install .......... done"
    
    log "[Info] installation directory: $INST_DIR"
}

if [ x"$PLATFORM" = x"" ] || [ "$PLATFORM" = "Failed" ] 
then
    die "[Error] Failed to get platform string, please check ${TRUNK_DIR}/src/get_PlatForm_str.sh"
fi

if [ $# -eq 1  ] && [ "$1" = "client" ]  ; then
        OP=client
fi

if [ $# -eq 2  ]; then
	if [ X"$1" = X"client" ]; then
		OP=client
	fi
	THIRD_DIR="$2"
	export SSL_LIB="$THIRD_DIR/dependency/$PLATFORM/openssl/comm/lib"
	export SSL_INCLUDE="$THIRD_DIR/dependency/$PLATFORM/openssl/comm/include"
fi
main
