#!/bin/bash
# Perform PL/Java lib installation.
# Copyright (c) Huawei Technologies Co., Ltd. 2010-2018. All rights reserved.
# description: the script that make install pljava libs
# date: 2019-5-16
# modified:
# version: 1.0
# history:
WORK_PATH="$(dirname ${0})"
source "${WORK_PATH}/build_global.sh"
#######################################################################
# build and install component
#######################################################################
function build_component()
{
    cd ${LOCAL_DIR}
    xz -k -d "${TAR_FILE_NAME}.xz"
    tar -xvf ${TAR_FILE_NAME}
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    # patch -p1 < ../huawei_llvm.patch
    if [ $? -ne 0 ]; then
        die "[Error] change dir to $SRC_DIR failed."
    fi
    rm -rf ${LOCAL_DIR}/build
    mkdir ${LOCAL_DIR}/build
    cd ${LOCAL_DIR}/build
    log "[Notice] llvm start configure"

    for COMPILE_TYPE in ${COMPLIE_TYPE_LIST}
    do
        case "${COMPILE_TYPE}" in
            release)
                die "[Error] llvm not supported build type."
                ;;
            debug)
                die "[Error] llvm not supported build type."
                ;;
            comm)
                mkdir -p ${LOCAL_DIR}/install_comm
                log "[Notice] llvm cmake string: cmake -G "Unix Makefiles" -DCMAKE_CXX_FLAGS='-fno-aggressive-loop-optimizations -D_GLIBCXX_USE_CXX11_ABI=0 -fexceptions' -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=${BUILD_TARGET} -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_C_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_comm ../${SOURCE_CODE_PATH}"
                cmake -G "Unix Makefiles" -DCMAKE_CXX_FLAGS='-fno-aggressive-loop-optimizations -D_GLIBCXX_USE_CXX11_ABI=0 -fexceptions' -DLLVM_ENABLE_ASSERTIONS=ON  -DCLANG_INCLUDE_TESTS=OFF -DCLANG_TOOL_CLANG_CHECK_BUILD=OFF -DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF -DCLANG_TOOL_CLANG_RENAME_BUILD=OFF -DCLANG_TOOL_CLANG_REFACTOR_BUILD=OFF -DCLANG_TOOL_CLANG_OFFLOAD_BUNDLER_BUILD=OFF -DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF -DCLANG_TOOL_CLANG_FORMAT_BUILD=OFF -DCLANG_TOOL_CLANG_EXTDEF_MAPPING_BUILD=OFF --DCMAKE_C_FLAGS='-fno-aggressive-loop-optimizations -fexceptions' -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=${BUILD_TARGET} -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_C_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_comm ../${SOURCE_CODE_PATH}
                ;;
            release_llt)
                die "[Error] llvm not supported build type."
                ;;
            debug_llt)
                die "[Error] llvm not supported build type."
                ;;
            llt)
                mkdir -p ${LOCAL_DIR}/install_llt
                log "[Notice] llvm cmake string: cmake -G "Unix Makefiles" -DCMAKE_CXX_FLAGS='-fno-aggressive-loop-optimizations -D_GLIBCXX_USE_CXX11_ABI=0' -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=${BUILD_TARGET} -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_C_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_comm ../${SOURCE_CODE_PATH}"
                cmake  -G "Unix Makefiles" -DCMAKE_CXX_FLAGS='-fno-aggressive-loop-optimizations -D_GLIBCXX_USE_CXX11_ABI=0 -fexceptions' -DLLVM_ENABLE_ASSERTIONS=ON -DCLANG_INCLUDE_TESTS=OFF  -DCLANG_TOOL_CLANG_CHECK_BUILD=OFF -DCLANG_TOOL_C_INDEX_TEST_BUILD=OFF -DCLANG_TOOL_CLANG_RENAME_BUILD=OFF -DCLANG_TOOL_CLANG_REFACTOR_BUILD=OFF -DCLANG_TOOL_CLANG_OFFLOAD_BUNDLER_BUILD=OFF -DCLANG_TOOL_CLANG_IMPORT_TEST_BUILD=OFF -DCLANG_TOOL_CLANG_FORMAT_BUILD=OFF -DCLANG_TOOL_CLANG_EXTDEF_MAPPING_BUILD=OFF -DCMAKE_C_FLAGS='-fno-aggressive-loop-optimizations -fexceptions' -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD=${BUILD_TARGET} -DCMAKE_CXX_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_C_FLAGS_RELEASE='-O2 -DNDEBUG' -DCMAKE_INSTALL_PREFIX=${LOCAL_DIR}/install_llt ../${SOURCE_CODE_PATH}
                ;;
            *)
                log "Internal Error: option processing error: $1"
                log "please write right paramenter in ${CONFIG_FILE_NAME}"
                exit 1
        esac

        if [ $? -ne 0 ]; then
           die "[Error] llvm configure failed."
        fi
        log "[Notice] llvm End configure"
        log "[Notice] llvm using \"${COMPILE_TYPE}\" Begin make"
        make -j16
        if [ $? -ne 0 ]; then
           die "llvm make failed."
        fi
        log "[Notice] llvm End make"


        log "[Notice] llvm using \"${COMPILE_TYPE}\" Begin make install"
        make install
        if [ $? -ne 0 ]; then
           die "llvm make install failed."
        fi
        log "[Notice] llvm End make install"
        # llvm has no distclean, using clean here.
        make clean
    done
}
#######################################################################
# clean component
#######################################################################
function clean_component()
{
    cd ${LOCAL_DIR}/${SOURCE_CODE_PATH}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR}/${SOURCE_CODE_PATH} failed."
    fi

    cd ${LOCAL_DIR}
    if [ $? -ne 0 ]; then
        die "[Error] cd ${LOCAL_DIR} failed."
    fi
    [ -n "${SOURCE_CODE_PATH}" ] && rm -rf ${SOURCE_CODE_PATH}
    rm -rf install_*

    log "[Notice] llvm clean has been finished!"
}
