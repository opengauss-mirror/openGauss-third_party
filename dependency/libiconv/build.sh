#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2020. All rights reserved.
# description: the script that make install libiconv
# date: 2020-04-18
# version: 1.16
# history:
# 2020-01-04 import libiconv-1.15 into open_source
# 2020-04-18 update libiconv-1.15 to libiconv-1.16

set -e
python $(pwd)/../../build/pull_open_source.py "libiconv" "libiconv-1.16.tar.gz" "05833PRU"

tar -zxvf $(pwd)/libiconv-1.16.tar.gz
iconv_dir=$(pwd)/libiconv-1.16/
build_dir=$(pwd)/install_comm

cd $iconv_dir
chmod 777 configure

./configure CFLAGS='-fPIC -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector' CPPFLAGS='-fPIC -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector' LDFLAGS='-Wl,-z,relro,-z,now' --prefix=$build_dir --disable-rpath

make clean
make -j4
make install
cd ..
cp -r install_comm install_llt
