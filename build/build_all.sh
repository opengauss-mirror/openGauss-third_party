#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install all of binarylibs
#  date: 2020-06-01
#  version: 1.0
#  history:
#
# *************************************************************************
set -e

ROOT_PATH=$(pwd)/../
OUTPUT_PATH=${ROOT_PATH}/output
PLATFORM_BUILD_PATH=${ROOT_PATH}/platform/build
TOOLS_BUILD_PATH=${ROOT_PATH}/buildtools
DEPENDENCY_BUILD_PATH=${ROOT_PATH}/dependency/build

# clean output dir
if [[ -d ${OUTPUT_PATH} ]]; then
    rm -rf ${OUTPUT_PATH}
fi

echo --------------------------------openssl-------------------------------------------------
start_tm=$(date +%s%N)
[ -f demo.log ] && rm -rf demo.log
cd $(pwd)/../dependency/openssl
python build.py -m all -f openssl-1.1.1g.tar.gz -t "comm|llt" >>../build/demo.log
end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "[openssl] $use_tm"

start_tm=$(date +%s%N)
# build platform
cd ${TOOLS_BUILD_PATH}
sh build_tools.sh

# build platform
cd ${PLATFORM_BUILD_PATH}
sh build_platform.sh

# build dependency
cd ${DEPENDENCY_BUILD_PATH}
sh build_dependency.sh

end_tm=$(date +%s%N)
use_tm=$(echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}' | xargs printf "%.2f")
echo "total build time:$use_tm"
