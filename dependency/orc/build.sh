#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install liborc
# date: 2020-11-26
# version: 1.1.0

set -e
python $(pwd)/../../build/pull_open_source.py "orc" "orc-rel-release-1.6.0.tar.gz" "05833RAN"
rm -rf orc-rel-release-1.6.0
tar -zxvf $(pwd)/orc-rel-release-1.6.0.tar.gz

patch -p0 < huawei_orc-rel-release-1.6.0.patch

platform=$(sh ../../build/get_PlatForm_str.sh)

cp ../lz4/install_comm  orc-rel-release-1.6.0/c++/libs/lz4 -rp
cp ../protobuf/install_comm/  orc-rel-release-1.6.0/c++/libs/protobuf -rp
cp snappy  orc-rel-release-1.6.0/c++/libs/snappy -rp
cp ../../output/dependency/$platform/zlib1.2.11/comm  orc-rel-release-1.6.0/c++/libs/zlib -rp
export PATH=$(pwd)/../../output/dependency/$platform/protobuf/comm/bin:$PATH
export LD_LIBRARY_PATH=$(pwd)/orc-rel-release-1.6.0/c++/libs:$LD_LIBRARY_PATH
export LIBS=$(pwd)/orc-rel-release-1.6.0/c++/libs
cd orc-rel-release-1.6.0

sed -i \
-e "32a set (PROTOBUF_INCLUDE_DIRS \"$LIBS/protobuf/include\")" \
-e "32a set (PROTOBUF_LIBRARIES \"$LIBS/protobuf/lib/libprotobuf.a\")" \
-e "32a set (PROTOBUF_EXECUTABLE `which protoc`)" \
-e "32a set (SNAPPY_INCLUDE_DIRS \"$LIBS/snappy/include\")" \
-e "32a set (SNAPPY_LIBRARIES \"$LIBS/snappy/lib/libsnappy.a\")" \
-e "32a set (ZLIB_INCLUDE_DIRS \"$LIBS/zlib/include\")" \
-e "32a set (ZLIB_LIBRARIES \"$LIBS/zlib/lib/libz.a\")" \
-e "32a set (LZ4_INCLUDE_DIRS \"$LIBS/lz4/include\")" \
-e "32a set (LZ4_LIBRARIES \"$LIBS/lz4/lib/liblz4.a\")" CMakeLists.txt


mkdir build
cd build
echo $PATH
cmake .. -DCMAKE_INSTALL_PREFIX=$(pwd)/install -DBUILD_JAVA=OFF -DBUILD_SHARED_LIBS=OFF
sed '/CXX_FLAGS/d' ./c++/src/CMakeFiles/orc.dir/flags.make
sed -i '5a CXX_FLAGS = -g -fPIC -DNDEBUG -O2 -fno-strict-aliasing -ffloat-store -L /lib64 -std=c++0x -O2 -D_GLIBCXX_USE_CXX11_ABI=0 -DORC_CXX_HAS_UNIQUE_PTR -DORC_CXX_HAS_NOEXCEPT -DORC_CXX_HAS_CSTDINT -DORC_CXX_HAS_NULLPTR -DORC_CXX_HAS_OVERRIDE -fstack-protector-all -Wl,--as-needed,-z,relro,-z,now -Wall -Wno-unknown-pragmas -Wconversion' ./c++/src/CMakeFiles/orc.dir/flags.make
make -j4
make install
mkdir -p ../../../../output/dependency/$platform/liborc/comm
mkdir -p ../../../../output/dependency/$platform/liborc/llt
rm -rf install/bin
cp -r install/* ../../../../output/dependency/$platform/liborc/comm
cp -r install/* ../../../../output/dependency/$platform/liborc/llt
cp ./c++/src/orc_proto.pb.h ../../../../output/dependency/$platform/liborc/comm/include
cp ./c++/src/orc_proto.pb.h ../../../../output/dependency/$platform/liborc/llt/include
cp ./c++/src/Adaptor.hh ../../../../output/dependency/$platform/liborc/comm/include/orc/
cp ./c++/src/Adaptor.hh ../../../../output/dependency/$platform/liborc/llt/include/orc/
cp ../c++/src/Exceptions.hh ../../../../output/dependency/$platform/liborc/comm/include/orc/
cp ../c++/src/Exceptions.hh ../../../../output/dependency/$platform/liborc/llt/include/orc/
