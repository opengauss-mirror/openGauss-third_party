#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install dependency
#  date: 2020-06-01
#  version: 1.0
#  history:
#
# *************************************************************************

export BUILD_SCRIPT_PATH=$(cd "$(dirname "$0")";pwd)
export OPEN_SOURCE=$(dirname $BUILD_SCRIPT_PATH)
export BUILD_TOOLS_PATH=${BUILD_SCRIPT_PATH}/../../buildtools

. ${BUILD_SCRIPT_PATH}/../../build/common.sh

function export_buildtools() {
    export CC=${BUILD_TOOLS_PATH}/gcc/install_comm/bin/gcc
    export CXX=${BUILD_TOOLS_PATH}/gcc/install_comm/bin/g++
    export LD_LIBRARY_PATH=${BUILD_TOOLS_PATH}/gmp/install_comm/lib:${BUILD_TOOLS_PATH}/mpfr/install_comm/lib:${BUILD_TOOLS_PATH}/mpc/install_comm/lib:${BUILD_TOOLS_PATH}/isl/install_comm/lib:${BUILD_TOOLS_PATH}/gcc/install_comm/lib64
    export PATH=${BUILD_TOOLS_PATH}/gcc/install_comm/bin:${BUILD_TOOLS_PATH}/cmake/install_comm/bin:$PATH
}

function build_first()
{
    build_item boost 
    build_item cJSON
    build_item zlib 
    build_item openssl
    build_item libevent
    build_item jemalloc
    build_item kerberos
    build_item libcurl
    build_item libedit
    build_item lz4
    build_item llvm
    build_item ncurses
    build_item protobuf
    build_item libxml2
    build_item libcgroup

    # miss
    # build_item libcurl
}

function build_second()
{
    build_item libthrift
    build_item double-conversion
    build_item brotli
    build_item snappy
    build_item zstd
    build_item glog
    build_item flatbuffers
    build_item rapidjson
    build_item arrow
    build_item orc
    # build_item pyyaml
    build_item c-ares
    build_item grpc
    build_item pcre
    build_item libiconv
    build_item nghttp2
    build_item esdk_obs_api
    build_item numactl
    build_item memcheck
}

function build_pylib()
{
    build_item six
    build_item pycparser
    build_item cffi
    build_item bcrypt
    build_item idna
    build_item ipaddress
    build_item netifaces
    build_item pynacl
    build_item asn1crypto
    build_item cryptography
    build_item pyOpenSSL
    build_item paramiko
    build_item psutil
    build_item pyasn1
    if [ -d $BUILD_SCRIPT_PATH/../install_comm ];then
        rm -rf $BUILD_SCRIPT_PATH/../install_comm
    fi
}

function main()
{
    cd $BUILD_SCRIPT_PATH
    rm -rf *.log
    total_start_tm=`date +%s%N`
    export_buildtools
    build_first
    build_second
    build_pylib
    total_end_tm=`date +%s%N`
    total_use_tm=`echo $total_end_tm $total_start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f"`
    echo "total time:$total_use_tm"
}

main
