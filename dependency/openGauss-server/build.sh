#!/bin/bash
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2020. All rights reserved.
# description: the script that pull openGauss-server source code
# date: 2020-11-17
# version: 1.0.0
# history:
# 2020-11-17 add openGauss-server

set -e
python $(pwd)/../../build/pull_open_source.py "openGauss-server" "opengauss-openGauss-server-1.0.0.tar.gz" "05836ECG"

