#!/bin/bash
# Copyright (c): 2012-2019, Huawei Tech. Co., Ltd.
set -e
python $(pwd)/../../build/pull_open_source.py "rapidjson" "rapidjson-4b3d7c2f42142f10b888e580c515f60ca98e2ee9.zip" "05833NMN"
unzip -o rapidjson-4b3d7c2f42142f10b888e580c515f60ca98e2ee9.zip
