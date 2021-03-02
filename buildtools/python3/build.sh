#!/bin/bash
#######################################################################
# Copyright (c): 2012-2021, Huawei Tech. Co., Ltd.
# description: the script that make install bcrypt
# version: 3.7.4
# date: 2020-01-21
# history:
#######################################################################
set -e

PLATFORM=$(sh $(pwd)/../../build/get_PlatForm_str.sh)

# At present, on the openEuler system, the openssl versin is lowwer than which is used in openGauss.
# we need to use high version openssl to build python3 for libpython3.*m.so.1.0 file.
# The following steps apply to Python3.7 . You can edit it for other Python version.
if [[ ${PLATFORM} != "openeuler_aarch64" &&  ${PLATFORM} != "openeuler_x86_64" ]]; then
    echo "Only openEuler system need to build this."
    exit 0
fi

SSL_PATH=$(pwd)/../../dependency/openssl/install/comm/
if [ ! -d  $SSL_PATH ]; then
    echo "Openssl in output dir is not exist. Please build openssl first."
    exit 0
fi

TARGET_PATH=$(pwd)/../../output/dependency/install_tools_$PLATFORM/

tar -xf ./Python-3.7.4.tar.xz
#add patch
cp ./00102-lib64.patch Python-3.7.4/
cp ./python3.7_ssl.patch Python-3.7.4/
cd Python-3.7.4/
patch -p1 < ./00102-lib64.patch
patch -p1 < ./python3.7_ssl.patch

#replace ssl path by openssl in output
sed -i "s#/usr/local/ssl#${SSL_PATH}#" ./Modules/Setup.dist

#compile python3
./configure --enable-shared --prefix=/usr
make -j
make install -j

mkdir -p ${TARGET_PATH}
#copy libpython.*.so to target patch
cp /usr/lib/libpython3.*m.so.1.0 ${TARGET_PATH}

echo "End build python3."