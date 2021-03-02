#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install snappy
# date: 2020-01-04
# version: 1.1.8

set -e

LOCAL_DIR=$(dirname "${LOCAL_PATH}")
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)
python $(pwd)/../../build/pull_open_source.py "snappy" "1.1.8.tar.gz" "05834ASH"
rm -rf snappy-1.1.8
rm -rf install_comm
tar -xvf $(pwd)/1.1.8.tar.gz

cd snappy-1.1.8
patch -p0 < ../huawei_snappy.patch
sed -i '2a set(CMAKE_POSITION_INDEPENDENT_CODE ON)' CMakeLists.txt
sed -i '3a set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIE -fPIC -g -O2")' CMakeLists.txt
sed -i '4a set(CMAKE_CPP_FLAGS "${CMAKE_CPP_FLAGS} -fPIE -fPIC -g -O2 -D_GLIBCXX_USE_CXX11_ABI=0")' CMakeLists.txt
sed -i '5a set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIE -fPIC -g -O2 -D_GLIBCXX_USE_CXX11_ABI=0")' CMakeLists.txt
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$(pwd)/../../install_comm
make CFLAGS="-fPIE -fPIC" -j4
make install
cd ../..
mv install_comm/lib64 install_comm/lib
rm -rf install_comm/lib/cmake
INSTALL_DIR=${LOCAL_DIR}/../../output/dependency/${PLAT_FORM_STR}/snappy
mkdir -p ${INSTALL_DIR}/comm
cp -r install_comm/* ${INSTALL_DIR}/comm
mkdir -p ${INSTALL_DIR}/llt
cp -r install_comm/* ${INSTALL_DIR}/llt
cp install_comm/lib/libsnappy.a ${INSTALL_DIR}/llt/lib/libsnappy_pic.a
rm -rf ../orc/snappy
mkdir -p ../orc/snappy
cp -r install_comm/*  ../orc/snappy
