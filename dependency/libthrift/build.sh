#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install thrift
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
set -e
python $(pwd)/../../build/pull_open_source.py "libthrift" "thrift-0.13.0.tar.gz" "05833QEA"

LOCAL_PATH=${0}
FIRST_CHAR=$(expr substr "$LOCAL_PATH" 1 1)
if [ "$FIRST_CHAR" = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi

LOCAL_DIR=$(dirname "${LOCAL_PATH}")
TRUNK_DIR=${LOCAL_DIR}/../../
PLATFORM=$(bash ${TRUNK_DIR}/build/get_PlatForm_str.sh)

tmp_cpus=$(grep -w processor /proc/cpuinfo|wc -l)

rm -rf thrift-0.13.0
export PACKAGE=thrift-0.13.0
[ -n "${PACKAGE}" ] && rm -rf ${PACKAGE}
tar xfz $PACKAGE.tar.gz
cd $PACKAGE
mkdir -p ../install_comm
dir=$(pwd)

export BOOST_HOME=$TRUNK_DIR/output/dependency/$PLATFORM/boost/comm
export OPENSSL_HOME=$TRUNK_DIR/output/dependency/$PLATFORM/openssl/comm
export C_INCLUDE_PATH=$TRUNK_DIR/output/dependency/$PLATFORM/openssl/comm/include:$C_INCLUDE_PATH
export LD_LIBRARY_PATH=$TRUNK_DIR/output/dependency/$PLATFORM/openssl/comm/lib:$TRUNK_DIR/output/dependency/$PLATFORM/boost/comm/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=$TRUNK_DIR/output/dependency/$PLATFORM/openssl/comm/lib:$TRUNK_DIR/output/dependency/$PLATFORM/boost/comm/lib:$LIBRARY_PATH


./bootstrap.sh
 patch  -p0 < ../huawei_thrift_0.13.0.patch
#请将prefix修改为全路径
./configure --with-cpp  --without-java --without-python --with-boost=$BOOST_HOME --with-openssl=$OPENSSL_HOME --with-go=no --with-qt4=no --with-qt5=no --with-zlib=no  CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0 -Wl,-z,relro,-z,now,-z,noexecstack -fstack-protector-strong -fPIC" LIBS="-lcrypto -ldl" --enable-static=yes --enable-shared=no --enable-tutorial=no --enable-tests=no --prefix=$dir/../install_comm

make -j${tmp_cpus}
make install

if [ ! -d ${TRUNK_DIR}/output/dependency/$PLATFORM/thrift ]; then
  mkdir -p ${TRUNK_DIR}/output/dependency/$PLATFORM/thrift
fi
rm -rf ${LOCAL_DIR}/install_comm/lib/pkgconfig
mkdir -pv ${LOCAL_DIR}/install_comm_dist
cp -r ${LOCAL_DIR}/install_comm/* ${LOCAL_DIR}/install_comm_dist
# 删除相同的宏定义
sed -i '317,334d' $LOCAL_DIR/install_comm_dist/include/thrift/config.h
cp -r ${LOCAL_DIR}/install_comm_dist/* ${TRUNK_DIR}/output/dependency/$PLATFORM/thrift
