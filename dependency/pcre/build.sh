#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install pcre
# date: 2020-06-24
# version: 8.44
# history:
# 2020-01-04 import pcre-8.42 into open_source
# 2020-06-24 upgrade pcre-8.42 to pcre-8.44

set -e
python $(pwd)/../../build/pull_open_source.py "pcre" "pcre-8.44.tar.gz" "05834AMQ"

tar -zxvf $(pwd)/pcre-8.44.tar.gz
pcre_dir=$(pwd)/pcre-8.44/
build_dir=$(pwd)/install_comm

cd $pcre_dir
chmod 777 configure

./configure CFLAGS='-fPIC -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector' CPPFLAGS='-fPIC -fstack-protector-all --param ssp-buffer-size=4 -Wstack-protector' LDFLAGS='-Wl,-z,relro,-z,now' --prefix=$build_dir --enable-utf --disable-rpath

make clean
make -j4
make install
cd ..
cp -r install_comm install_llt
