#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install zstd
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
set -e
python $(pwd)/../../build/pull_open_source.py "zstd" "zstd-1.4.4.tar.gz" "05833RAA"

LOCAL_DIR=$(pwd)
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)

export PACKAGE=zstd-1.4.4
[ -n "${PACKAGE}" ] && rm -rf ${PACKAGE} 
tar xfz $PACKAGE.tar.gz
cd $PACKAGE
mkdir -p ../install_comm/lib/
cd build/cmake/
mkdir build
cd build
cmake -DZSTD_BUILD_STATIC=on -DCMAKE_INSTALL_PREFIX=../../../../install_comm ..
sed -i 's/-std=c99/-std=c99 -Wl,-z,relro,-z,now,-z,noexecstack -fPIC/g' ./programs/CMakeFiles/zstd.dir/flags.make
sed -i 's/-std=c99/-std=c99 -Wl,-z,relro,-z,now,-z,noexecstack -fPIC/g' ./programs/CMakeFiles/zstd.dir/link.txt
sed -i 's/-std=c99/-std=c99 -Wl,-z,relro,-z,now,-z,noexecstack -fPIC/g' ./programs/CMakeFiles/zstd-frugal.dir/flags.make
sed -i 's/-std=c99/-std=c99 -Wl,-z,relro,-z,now,-z,noexecstack -fPIC/g' ./programs/CMakeFiles/zstd-frugal.dir/link.txt
sed -i 's/-std=c99/-std=c99 -Wl,-z,relro,-z,now,-z,noexecstack -fPIC/g' ./lib/CMakeFiles/libzstd_static.dir/flags.make
sed -i 's/-std=c99/-std=c99 -Wl,-z,relro,-z,now,-z,noexecstack -fPIC/g' ./lib/CMakeFiles/libzstd_static.dir/link.txt
sed -i 's/-std=c99/-std=c99 -Wl,-z,relro,-z,now,-z,noexecstack -fPIC/g' ./lib/CMakeFiles/libzstd_shared.dir/flags.make
sed -i 's/-std=c99/-std=c99 -Wl,-z,relro,-z,now,-z,noexecstack -fPIC/g' ./lib/CMakeFiles/libzstd_shared.dir/link.txt
make -j4
make install
mv  ../../../../install_comm/lib64/libzstd* ../../../../install_comm/lib/

INSTALL_DIR=${LOCAL_DIR}/../../output/dependency/${PLAT_FORM_STR}/zstd
# copy lib to destination
mkdir -p ${INSTALL_DIR}/bin
mkdir -p ${INSTALL_DIR}/include
mkdir -p ${INSTALL_DIR}/lib

cp ${LOCAL_DIR}/install_comm/bin/* ${INSTALL_DIR}/bin/
cp ${LOCAL_DIR}/install_comm/include/* ${INSTALL_DIR}/include/
cp ${LOCAL_DIR}/install_comm/lib/libzstd.a ${INSTALL_DIR}/lib/

