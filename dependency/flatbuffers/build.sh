#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install flatbuffers
#  date: 2020-01-16
#  version: 1.0
#  history:
#
# *************************************************************************
set -e
python $(pwd)/../../build/pull_open_source.py "flatbuffers" "flatbuffers-1.11.0-src.zip" "05833LKH"
tmp_cpus=$(grep -w processor /proc/cpuinfo|wc -l)

unzip -o flatbuffers-1.11.0-src.zip
wait
export PACKAGE=flatbuffers-1.11.0
[ -n "${PACKAGE}" ] && rm -rf ${PACKAGE} 
tar xfz $PACKAGE.tar.gz
cd $PACKAGE
mkdir -p ../install_comm
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=../install_comm
make SFLAGS="-O3 -fPIC -fstack-protector-strong -Wl,-z,noexecstack -Wl,-z,relro,-z,now  -D_LARGEFILE64_SOURCE=1 -DHAVE_HIDDEN" -j${tmp_cpus}
make install


