#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install nghttp2
# date: 2020-11-16
# version: 1.41.0
# history:
# upgrade from 1.39.2 to 1.41.0

set -e
python $(pwd)/../../build/pull_open_source.py "nghttp2" "nghttp2-1.41.0.tar.gz" "05835WNC"
tmp_cpus=$(grep -w processor /proc/cpuinfo|wc -l)

tar -zxvf $(pwd)/nghttp2-1.41.0.tar.gz
nghttp2_dir=$(pwd)/nghttp2-1.41.0
build_dir=$(pwd)/install_comm

cd $nghttp2_dir
autoreconf -i
automake
autoconf
chmod 777 configure

./configure CFLAGS='-fPIC -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector' CPPFLAGS='-fPIC -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector' LDFLAGS='-Wl,-z,relro,-z,now' --prefix=$build_dir --disable-rpath

make clean
make -j${tmp_cpus}
make install
cd ..
cp -r install_comm install_llt
