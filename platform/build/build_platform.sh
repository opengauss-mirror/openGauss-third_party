#!/bin/bash
# *************************************************************************
# Copyright: (c) Huawei Technologies Co., Ltd. 2020. All rights reserved
#
#  description: the script that make install platform
#  date: 2020-10-21
#  version: 1.0
#  history:
#
# *************************************************************************
set -e

ROOT_PATH=$(pwd)/../../
PLATFORM_PATH=${ROOT_PATH}/platform

# build huawei secure c lib
cd ${PLATFORM_PATH}/Huawei_Secure_C
sh build.sh -m all

# abu lib
cd ${PLATFORM_PATH}/abu
sh ./build.sh

# AdaptiveLM lib
cd ${PLATFORM_PATH}/AdaptiveLM_C_V100R005C01SPC002
sh ./build.sh

# build huawei secure c lib
#cd ${PLATFORM_PATH}/hotpatch
#if [[ -d "${PLATFORM_PATH}/hotpatch/DOPRA SSP V300R020C00SPC135B100" ]]; then
#    rm -rf ${PLATFORM_PATH}/hotpatch/DOPRA SSP V300R020C00SPC135B100
#fi
#sh ./build.sh

# build huawei jdk
cd ${PLATFORM_PATH}/openjdk8
sh ./build.sh
