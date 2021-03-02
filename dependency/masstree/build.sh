#!/bin/bash
#  Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
#  description: the script that make install masstree
#  date: 2020-12-16
#  version: 1.0
#  history:
#    2020-12-16 first version

set -e
#python $(pwd)/../../build/pull_open_source.py "masstree" "masstree-beta-0.9.0.zip" "05833MXJ"

# change compress type
#unzip masstree-beta-0.9.0.zip &> /dev/null
#tar -czf masstree-beta-0.9.0.tar.gz masstree-beta-0.9.0
rm -fr masstree-beta-0.9.0
rm -f masstree-beta-0.9.0.zip

CUR_DIR=$(pwd)
MASSTREE_PACKAGE=masstree-beta-0.9.0
MOT_MASSTREE_PATCH=masstree-beta-0.9.0_patch
MASSTREE_MEGRED_SOURCES_DIR=code
MASSTREE_SOURCES_TMP_DIR=tmp

MASSTREE_RELEVANT_SOURCES=(
                btree_leaflink.hh
                circular_int.hh
                compiler.hh
                hashcode.hh
                kpermuter.hh
                ksearch.hh
                masstree_get.hh
                masstree.hh
                masstree_insert.hh
                masstree_key.hh
                masstree_remove.hh
                masstree_scan.hh
                masstree_split.hh
                masstree_struct.hh
                masstree_tcursor.hh
                memdebug.hh
                mtcounters.hh
                kvthread.cc
                kvthread.hh
                nodeversion.hh
                small_vector.hh
                straccum.cc
                straccum.hh
                str.hh
                stringbag.hh
                string_base.hh
                string.cc
                string.hh
                string_slice.hh
                timestamp.hh)

rm -rf $MASSTREE_SOURCES_TMP_DIR
rm -rf $MASSTREE_MEGRED_SOURCES_DIR
mkdir $MASSTREE_SOURCES_TMP_DIR
mkdir $MASSTREE_MEGRED_SOURCES_DIR
tar xfzv $CUR_DIR/$MASSTREE_PACKAGE.tar.gz -C $MASSTREE_SOURCES_TMP_DIR &> /dev/null
for src_file in "${MASSTREE_RELEVANT_SOURCES[@]}"
do
     cp $MASSTREE_SOURCES_TMP_DIR/$MASSTREE_PACKAGE/$src_file $MASSTREE_MEGRED_SOURCES_DIR
done
rename ".cc" ".cpp" $MASSTREE_MEGRED_SOURCES_DIR/*.cc
rm -rf $MASSTREE_SOURCES_TMP_DIR
patch -d $MASSTREE_MEGRED_SOURCES_DIR < $CUR_DIR/$MOT_MASSTREE_PATCH.patch

cd $MASSTREE_MEGRED_SOURCES_DIR
make -sj
rm -rf *.o
cd ..

LOCAL_DIR=$(dirname "${LOCAL_PATH}")
PLAT_FORM_STR=$(sh ${LOCAL_DIR}/../../build/get_PlatForm_str.sh)
INSTALL_DIR=${LOCAL_DIR}/../../output/dependency/${PLAT_FORM_STR}/masstree
mkdir -p ${INSTALL_DIR}/comm/include
mkdir -p ${INSTALL_DIR}/comm/lib
cp ${MASSTREE_MEGRED_SOURCES_DIR}/*.h* ${INSTALL_DIR}/comm/include
cp ${MASSTREE_MEGRED_SOURCES_DIR}/libmasstree.so ${INSTALL_DIR}/comm/lib

