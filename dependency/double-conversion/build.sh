#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install double-conversion
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
set -e
python $(pwd)/../../build/pull_open_source.py "double-conversion" "v3.1.1.zip" "05833DJM"

export PACKAGE=double-conversion-3.1.1
[ -n "${PACKAGE}" ] && rm -rf ${PACKAGE}
unzip v3.1.1.zip
cd $PACKAGE
mkdir build
mkdir install
cd build
cmake -DCMAKE_INSTALL_PREFIX=../../install_comm  ..
sed -i 's/CXX_FLAGS =/CXX_FLAGS = -D_GLIBCXX_USE_CXX11_ABI=0 -fPIC/g' CMakeFiles/double-conversion.dir/flags.make
make
make install
