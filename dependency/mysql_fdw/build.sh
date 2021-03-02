#!/bin/bash
#  Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
#  description: the script that make install lz4
#  date: 2020-12-16
#  version: 1.0
#  history:
#    2020-12-16 first version

set -e

python $(pwd)/../../build/pull_open_source.py "mysql_fdw" "mysql_fdw-REL-2_5_5.tar.gz" "05837EYW"
