#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install arrow
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
set -e
python $(pwd)/../../build/pull_open_source.py "parquet" "apache-arrow-0.11.1.zip" "05833DJU"

tmp_cpus=$(grep -w processor /proc/cpuinfo|wc -l)

LOCAL_PATH=${0}
FIRST_CHAR=$(expr substr "$LOCAL_PATH" 1 1)
if [ "$FIRST_CHAR" = "/" ]; then
    LOCAL_PATH=${0}
else
    LOCAL_PATH="$(pwd)/${LOCAL_PATH}"
fi

LOCAL_DIR=$(dirname "${LOCAL_PATH}")
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)
ROOT_DIR="${LOCAL_DIR}/../../"
export PACKAGE=arrow-apache-arrow-0.11.1
[ -n "${PACKAGE}" ] && rm -rf ${PACKAGE}
#tar xfz $PACKAGE.tar.gz
unzip apache-arrow-0.11.1.zip
cd $PACKAGE
cd cpp
mkdir build
cd build
mkdir install
dir=$(pwd)

rm -rf ${LOCAL_DIR}/install_*

export BOOST_ROOT=${LOCAL_DIR}/../boost/install_comm
export ZLIB_HOME=${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/zlib1.2.11/comm
export THRIFT_HOME=${LOCAL_DIR}/../libthrift/install_comm
export LZ4_HOME=${LOCAL_DIR}/../lz4/install_comm
export DOUBLE_CONVERSION_HOME=${LOCAL_DIR}/../double-conversion/install_comm
export BROTLI_HOME=${LOCAL_DIR}/../brotli/install_comm
export SNAPPY_HOME=${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/snappy/comm
export ZSTD_HOME=${LOCAL_DIR}/../zstd/install_comm
export GLOG_HOME=${LOCAL_DIR}/../glog/install_comm
export FLATBUFFERS_HOME=${LOCAL_DIR}/../flatbuffers/install_comm
export RAPIDJSON_HOME=${LOCAL_DIR}/../rapidjson/rapidjson-4b3d7c2f42142f10b888e580c515f60ca98e2ee9/include
cp $RAPIDJSON_HOME/rapidjson ../src/ -rf

sed -i "17a #include <cmath> " ../src/parquet/statistics.cc
sed -i "471d" ../cmake_modules/ThirdpartyToolchain.cmake
sed -i "472a set(DOUBLE_CONVERSION_INCLUDE_DIR "${DOUBLE_CONVERSION_HOME}/include")" ../cmake_modules/ThirdpartyToolchain.cmake
sed -i "473a set(DOUBLE_CONVERSION_STATIC_LIB "${DOUBLE_CONVERSION_HOME}/lib/libdouble-conversion.a")" ../cmake_modules/ThirdpartyToolchain.cmake

if [[ $PLAT_FORM_STR =~ "aarch64" ]];then
    sed -i "24d" ../cmake_modules/SetupCxxFlags.cmake
    sed -i "22d" ../cmake_modules/SetupCxxFlags.cmake
fi
APPEND_LDFLAGS+="-Wl,-z,relro,-z,now,-z,noexecstack -pie"
APPEND_FLAGS+="-fstack-protector-strong"
cmake .. -DCMAKE_BUILD_TYPE=release  -DARROW_PARQUET=ON  -DARROW_BUILD_TESTS=OFF  -DPARQUET_BUILD_EXAMPLES=OFF  -DPARQUET_BUILD_EXECUTABLES=OFF  -DARROW_WITH_BROTLI=ON -DARROW_WITH_LZ4=ON -DARROW_WITH_SNAPPY=ON -DARROW_WITH_ZLIB=ON -DARROW_WITH_ZSTD=ON -DARROW_BOOST_USE_SHARED=OFF  -DARROW_IPC=ON -DPARQUET_ARROW_LINKAGE=static -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_comm -DCMAKE_CXX_FLAGS="-fPIC -std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0 $APPEND_FLAGS $APPEND_LDFLAGS" -DCMAKE_C_FLAGS=" $APPEND_FLAGS $APPEND_LDFLAGS"  -DARROW_INSTALL_NAME_RPATH=OFF -DPTHREAD_LIBRARY="" 

cd ../../
cd cpp/build
make CFLAGS="-O3 -fPIE -fPIC -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDD" -j${tmp_cpus}
make parquet -j${tmp_cpus}
make install -sj

mv ${LOCAL_DIR}/install_comm/lib64 ${LOCAL_DIR}/install_comm/lib
rm -rf ${LOCAL_DIR}/install_comm/lib/*.a ${LOCAL_DIR}/install_comm/lib/libarrow.so* ${LOCAL_DIR}/install_comm/lib/pkgconfig
mkdir -p ${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/libparquet/comm
mkdir -p ${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/libparquet/llt
cp -r ${LOCAL_DIR}/install_comm/* ${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/libparquet/comm 
cp -r ${LOCAL_DIR}/install_comm/* ${ROOT_DIR}/output/dependency/${PLAT_FORM_STR}/libparquet/llt
