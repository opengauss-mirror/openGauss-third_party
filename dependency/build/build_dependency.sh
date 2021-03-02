#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install dependency
#  date: 2020-10-21
#  version: 1.0
#  history:
#
# *************************************************************************
set -e

ARCH=`uname -m`
ROOT_DIR="${PWD}/../.."
PLATFORM="$(bash ${ROOT_DIR}/build/get_PlatForm_str.sh)"

[ -f build_all.log ] && rm -rf build_all.log
echo ------------------------------commons-codec----------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../commons-codec
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[commons-codec] is " $use_tm
echo ------------------------------commons-logging--------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../commons-logging
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[commons-logging] is"  $use_tm
echo ------------------------------fastjson---------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../fastjson
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo " [fastjson] is " $use_tm
echo ------------------------------httpclient-------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../httpclient
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo  "[httpclient] is"  $use_tm
echo ------------------------------httpcore---------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../httpcore
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[httpcore] is" $use_tm
echo ------------------------------jackson----------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../jackson
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[jackson] is " $use_tm
echo ------------------------------joda-time--------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../joda-time
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[joda-time] is " $use_tm
echo ------------------------------slf4j------------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../slf4j
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[slf4j] is " $use_tm
echo ------------------------------cJSON------------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../cJSON
sh build.sh -m all >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[cJSON] is " $use_tm
echo ------------------------------jemalloc---------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../jemalloc
python build.py -m all -f jemalloc-5.2.1.tar.gz -t "release|debug" >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[jemalloc] is " $use_tm
echo ------------------------------libcgroup--------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../libcgroup
python build.py -m all -f libcgroup-0.41-21.el7.src.rpm -t "comm|llt" >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[libcgroup] is " $use_tm
echo ------------------------------numactl----------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../numactl
python build.py -m all -f numactl-2.0.13.tar.gz -t "comm|llt" >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[numactl] is " $use_tm
echo ------------------------------unixodbc--------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../unixodbc
sh build.sh -m all >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[unixodbc] is " $use_tm
echo ------------------------------fio--------------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../fio
python build.py -m all -f fio-fio-3.8.tar.gz -t comm >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[fio] is " $use_tm
echo ------------------------------iperf-------------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../iperf
python build.py -m all -f iperf-3.7.tar.gz -t comm >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[iperf] is " $use_tm
echo -------------------------------llvm------------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../llvm
sh -x build.sh -m all >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo $use_tm
echo -------------------------------asn1crypto-------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../asn1crypto
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[asn1crypto] $use_tm"
echo ---------------------------------six-----------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../six
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[six] $use_tm"
echo -------------------------------ipaddres--------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../ipaddress
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[ipaddress] $use_tm"
#echo ---------------------------------enum34--------------------------------------------------
#start_tm=$(date +%s%N)
#cd $(pwd)/../enum34
#sh build.sh >>../build/demo.log
#end_tm=$(date +%s%N)
#use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
#echo "[enum34] $use_tm"

#第一层依赖
echo -------------------------------pycparser-------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../pycparser
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[pycparser] $use_tm"
echo ---------------------------------cffi----------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../cffi
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[cffi] $use_tm"
echo -------------------------------cryptography----------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../cryptography
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[cryptography] $use_tm"

#无依赖
echo ---------------------------------bcrypt--------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../bcrypt
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[bcrypt] $use_tm"
#echo ---------------------------------bottle--------------------------------------------------
#start_tm=$(date +%s%N)
#cd $(pwd)/../bottle
#sh build.sh >>../build/demo.log
#end_tm=$(date +%s%N)
#use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
#echo "[bottle] $use_tm"
echo ---------------------------------libedit-------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../libedit
python build.py -m all -f libedit-20190324-3.1.tar.gz -t "comm|llt" >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[libedit] $use_tm"
echo ----------------------------------idna---------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../idna
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[idna] $use_tm"
#echo --------------------------------kafka-python---------------------------------------------
#start_tm=$(date +%s%N)
#cd $(pwd)/../kafka-python
#sh build.sh >>../build/demo.log
#end_tm=$(date +%s%N)
#use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
#echo "[kafka-python] $use_tm"
echo ----------------------------------nanomsg------------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../nanomsg
python build.py -m all -f nanomsg-1.1.5.tar.gz -t "comm" >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[nanomsg] $use_tm"
echo ----------------------------------netifaces----------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../netifaces
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[netifaces] $use_tm"
#echo -------------------------------------paste-----------------------------------------------
#start_tm=$(date +%s%N)
#cd $(pwd)/../paste
#sh build.sh >>../build/demo.log
#end_tm=$(date +%s%N)
#use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
#echo "[paste] $use_tm"
echo -------------------------------------psutil----------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../psutil
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[psutil] $use_tm"
echo -------------------------------------pyasn1----------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../pyasn1
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[pyasn1] $use_tm"

#有依赖
echo --------------------------------------pynacl---------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../pynacl
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[pynacl] $use_tm"
echo -----------------------------------paramiko----------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../paramiko
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[paramiko] $use_tm"
echo --------------------------------------pyOpenSSL------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../pyOpenSSL
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[pyOpenSSL] $use_tm"
echo -----------------------------------------lz4---------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../lz4
sh build.sh -m all >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[lz4] $use_tm"
echo -----------------------------------------zlib--------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../zlib
sh build.sh -m all >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[zlib] $use_tm"
echo --------------------------------------masstree-------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../masstree
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[masstree] $use_tm"
echo -----------------------------------------boost-------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../boost
sh build.sh -m all >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[boost] $use_tm"
echo ----------------------------------------brotli-------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../brotli
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[brotli] $use_tm"
echo -----------------------------------double-conversion-------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../double-conversion
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[double-conversion] $use_tm"
echo -----------------------------------------glog--------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../glog
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[glog] $use_tm"
echo -------------------------------------flatbuffers-----------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../flatbuffers
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[flatbuffers] $use_tm"
echo --------------------------------------rapidjson------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../rapidjson
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[rapidjson] $use_tm"
echo ----------------------------------------snappy-------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../snappy
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[snappy] $use_tm"
echo -----------------------------------------zstd--------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../zstd
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[zstd] $use_tm"
echo --------------------------------------libthrift------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../libthrift
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[libthrift] $use_tm"
echo ----------------------------------------parquet------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../parquet
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[parquet] $use_tm"
echo ---------------------------------------protobuf------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../protobuf
python build.py -m all -f protobuf-3.11.3.zip -t "comm|llt" >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[protobuf] $use_tm"
echo ----------------------------------------c-ares-------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../c-ares
sh build.sh -m all >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[c-ares] $use_tm"
echo --------------------------------------abseil-cpp-----------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../abseil-cpp
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[abseil-cpp] $use_tm"
echo -----------------------------------------grpc--------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../grpc
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[grpc] $use_tm"
echo -----------------------------------------orc---------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../orc
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[orc] $use_tm"
echo ---------------------------------------libevent------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../libevent
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[libevent] $use_tm"
echo --------------------------------------kerberos-------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../kerberos
python build.py -m all -f krb5-1.17.1.tar.gz -t "comm|llt" >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[kerberos] $use_tm"
echo ---------------------------------------libcurl-------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../libcurl
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[libcurl] $use_tm"
echo --------------------------------------libiconv-------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../libiconv
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[libiconv] $use_tm"
echo ---------------------------------------libxml2------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../libxml2
sh build.sh -m all >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[libxml2] $use_tm"
echo ---------------------------------------nghttp2------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../nghttp2
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[nghttp2] $use_tm"
echo ----------------------------------------pcre---------------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../pcre
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[pcre] $use_tm"
echo ---------------------------------------esdk_obs_api--------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../esdk_obs_api
sh build.sh >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[esdk_obs_api] $use_tm"

echo ---------------------------------------etcd--------------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../etcd
sh build.sh build "$ROOT_DIR/output/" >>../build/demo.log
sh build.sh client >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[etcd] $use_tm"
echo ---------------------------------------postgresql-hll-----------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../postgresql-hll
sh build.sh -m only_so >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[postgresql-hll] $use_tm"
#echo ---------------------------------------kmc---------------------------------------------
#start_tm=$(date +%s%N)
#cd $(pwd)/../../platform/kmc
#sh build.sh >>../../dependency/build/demo.log
#end_tm=$(date +%s%N)
#use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
#echo "[kmc] $use_tm"
echo ---------------------------------------pljava-----------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../pljava
sh build.sh -m build >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[pljava] $use_tm"

echo ---------------------------------------java-sdk-core-----------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../javasdkcore
sh build.sh -m build >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[javasdkcore] $use_tm"

echo ---------------------------------------mysql_fdw-----------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../mysql_fdw
sh build.sh -m build >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[mysql_fdw] $use_tm"

echo ---------------------------------------oracle_fdw-----------------------------------
start_tm=$(date +%s%N)
cd $(pwd)/../oracle_fdw
sh build.sh -m build >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[oracle_fdw] $use_tm"