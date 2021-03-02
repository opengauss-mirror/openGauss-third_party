#!/bin/bash
#  Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
#  description: the script that make install lz4
#  date: 2020-12-16
#  version: 1.0
#  history:
#    2020-12-16 first version

set -e

python $(pwd)/../../build/pull_open_source.py "oracle_fdw"  "ORACLE_FDW_2_1_0.zip" "05833BFB"
