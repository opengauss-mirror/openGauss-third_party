#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install glog
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
set -e
python $(pwd)/../../build/pull_open_source.py "glog" "glog-0.4.0.tar.gz" "05833NWR"

export PACKAGE=glog-0.4.0
[ -n "${PACKAGE}" ] && rm -rf ${PACKAGE}
tar xfz $PACKAGE.tar.gz
cd $PACKAGE
mkdir -p ../install_comm
dir=$(pwd)
#请修改未本机的全路径
echo $dir
./autogen.sh
./configure CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0  -fPIC"  --enable-static=yes --enable-shared=no --prefix=$dir/../install_comm
make -j4
make install


