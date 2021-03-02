#!/usr/bin/env python
# coding=utf-8
# description: Python script for open source software build.
# Copyright (c) 2020 Huawei Technologies Co.,Ltd.
# date: 2020-06-08

#---------------------------------------------------------------------------------#
#usage:                                                                           #
#   python3/python build.py -m all -f protobuf-3.11.3.zip -t "comm|llt"           #
#   -m: build mode include all|build|shrink|dist|clean                            #
#   -t: build type include comm|llt|release|debug                                 #
#   -f: tar file name                                                             #
#---------------------------------------------------------------------------------#

import os
import subprocess
import sys
import argparse
import subprocess

#--------------------------------------------------------#
# open source software build operator                    #
#--------------------------------------------------------#

class OPOperator():
    def __init__(self, mode, filename, compiletype):
        self.mode = mode
        self.filename = filename
        self.local_dir = os.getcwd()
        self.compiletype = compiletype.split('|')
        self.proto_dir = 'protobuf-3.11.3'

#--------------------------------------------------------#
# parser build source code folder parameter              #
#--------------------------------------------------------#

    def folder_parser(self):
        ls_cmd = 'cd %s; ls ' % (self.local_dir)
        file_str = os.popen(ls_cmd).read()
        file_list = file_str.split('\n')
        for pre_str in file_list:
            if pre_str.find('.zip') != -1:
                source_code = pre_str.split(".zip", 1)
                break
        return source_code[0]

#--------------------------------------------------------#
# parser binary libs parameter                           #
#--------------------------------------------------------#

    def binary_parser(self):
        binary_list = []
        platform_cmd = 'sh %s/../../build/get_PlatForm_str.sh' % (self.local_dir)
        platform_list = os.popen(platform_cmd).read().split('\n')
        platform_str = platform_list[0]
        if platform_str == 'euleros2.0_sp2_x86_64':
            binary_list.append(platform_str)
        elif platform_str == 'euleros2.0_sp5_x86_64':
            binary_list.append(platform_str)
        elif platform_str == 'centos7.6_x86_64':
            binary_list.append(platform_str)
        elif platform_str == 'euleros2.0_sp8_aarch64':
            binary_list.append(platform_str)
        elif platform_str == 'openeuler_aarch64':
            binary_list.append(platform_str)
        elif platform_str == 'openeuler_x86_64':
            binary_list.append(platform_str)
        elif platform_str == 'kylin_aarch64':
            binary_list.append(platform_str)
        else:
            print("[ERROR] Not supported platform type")
            assert False
        return binary_list

#--------------------------------------------------------#
# parser build mode parameter                            #
#--------------------------------------------------------#

    def build_mode(self):
        # check if support platform 
        self.binary_parser()
        # build mode
        if self.mode == 'build':
            self.build_component()
        elif self.mode == 'all':
            self.build_all()
        elif self.mode == 'shrink':
            self.shrink_component()
        elif self.mode == 'clean':
            self.clean_component()
        elif self.mode == 'dist':
            self.dist_component()
        else:
            print("[ERROR] Unrecognized build parameters, assert!")
            assert False

#--------------------------------------------------------#
# error log handler                                      #
#--------------------------------------------------------#

    def error_handler(self, ret):
        if ret:
            print("[ERROR] Invalid return code, exited")
            assert False

#--------------------------------------------------------#
# build all mode                                         #
#--------------------------------------------------------#

    def build_all(self):
        self.build_component()
        self.shrink_component()
        self.dist_component()
        self.clean_component()

#--------------------------------------------------------#
# build component mode                                   #
#--------------------------------------------------------#

    def build_component(self):
        # download source package
        download_cmd = 'python $(pwd)/../../build/pull_open_source.py "protobuf" "protobuf-3.11.3.zip" "05834KWC"'
        ret = self.exe_cmd(download_cmd)
        # tar open source package
        unzip_cmd = 'cd %s; unzip -o %s' % (self.local_dir, self.filename)
        ret = self.exe_cmd(unzip_cmd)
        source_code_path = self.folder_parser()
        get_cpu_cmd = 'grep -w processor /proc/cpuinfo|wc -l'
        status, output = subprocess.getstatusoutput(get_cpu_cmd)
        cpu_num = output.strip()
        # compile source code type
        for c_type in self.compiletype:
            if c_type == 'comm':
                config_cmd = "mkdir -p %s/install_comm; cd %s/%s/cmake;  sed -i '18a set(CMAKE_CXX_FLAGS \"${CMAKE_CXX_FLAGS} -fPIE -fPIC -fstack-protector-all -Wstack-protector -s -Wl,-z,relro,-z,now -D_GLIBCXX_USE_CXX11_ABI=0\")' CMakeLists.txt" % (self.local_dir, self.local_dir, self.proto_dir)
                ret = self.exe_cmd(config_cmd)
                self.error_handler(ret)
                make_cmd = 'cd %s/%s/cmake; cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../../install_comm -Dprotobuf_BUILD_TESTS=OFF; make CFLAGS="-fPIE -fPIC" -j%s  && make install' % (self.local_dir, self.proto_dir, cpu_num)
                ret = self.exe_cmd(make_cmd)
                self.error_handler(ret)
                mv_cmd = 'mv %s/install_comm/lib64 %s/install_comm/lib' % (self.local_dir, self.local_dir)
                self.exe_cmd(mv_cmd)
            elif c_type == 'llt':
                config_cmd = "mkdir -p %s/install_llt; cd %s/%s/cmake;  sed -i '18a set(CMAKE_CXX_FLAGS \"${CMAKE_CXX_FLAGS} -fPIE -fPIC -fstack-protector-all -Wstack-protector -s -Wl,-z,relro,-z,now -D_GLIBCXX_USE_CXX11_ABI=0\")' CMakeLists.txt" % (self.local_dir, self.local_dir, self.proto_dir)
                ret = self.exe_cmd(config_cmd)
                self.error_handler(ret)
                make_cmd = 'cd %s/%s/cmake; cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../../install_llt -Dprotobuf_BUILD_TESTS=OFF; make CFLAGS="-fPIE -fPIC" -j%s  && make install' % (self.local_dir, self.proto_dir, cpu_num)
                ret = self.exe_cmd(make_cmd)
                self.error_handler(ret)
                mv_cmd = 'mv %s/install_llt/lib64 %s/install_llt/lib' % (self.local_dir, self.local_dir)
                self.exe_cmd(mv_cmd)
            elif c_type == 'release':
                print ("[WARNING] Not supported build type")
            elif c_type == 'debug':
                print ("[WARNING] Not supported build type")
            else:
                print ("[WARNING] Not supported build type")
        # finish compile
        print ("[INFO] Build component finished")

#--------------------------------------------------------#
# copy open source component for using mode              #
#--------------------------------------------------------#

    def shrink_component(self):
        # shrink source code type
        for c_type in self.compiletype:
            if c_type == 'comm':
                install_dist_cmd = 'mkdir -p %s/install_comm_dist' % (self.local_dir)
                ret = self.exe_cmd(install_dist_cmd)
                self.error_handler(ret)
                cp_cmd1 = 'cp -r %s/install_comm/* %s/install_comm_dist' % (self.local_dir, self.local_dir)
                self.exe_cmd(cp_cmd1)
                rm_cmd = 'rm -rf %s/install_comm_dist/lib/*so* %s/install_comm_dist/lib/libprotobuf.la %s/install_comm_dist/lib/libprotobuf-lite.* %s/install_comm_dist/lib/libprotoc.* %s/install_comm_dist/lib/pkgconfig' % (self.local_dir, self.local_dir, self.local_dir, self.local_dir, self.local_dir)
                self.exe_cmd(rm_cmd)
            elif c_type == 'llt':
                install_llt_cmd = 'mkdir -p %s/install_llt_dist' % (self.local_dir)
                ret = self.exe_cmd(install_llt_cmd)
                self.error_handler(ret)
                cp_cmd1 = 'cp -r %s/install_llt/* %s/install_llt_dist' % (self.local_dir, self.local_dir)
                self.exe_cmd(cp_cmd1)
                mv_cmd = 'mv %s/install_llt_dist/lib/libprotobuf.a %s/install_llt_dist/lib/libprotobuf_pic.a' % (self.local_dir, self.local_dir)
                self.exe_cmd(mv_cmd)
                rm_cmd = 'rm -rf %s/install_llt_dist/lib/*so* %s/install_llt_dist/lib/libprotobuf.la %s/install_llt_dist/lib/libprotobuf-lite.* %s/install_llt_dist/lib/libprotoc.* %s/install_llt_dist/lib/pkgconfig' % (self.local_dir, self.local_dir, self.local_dir, self.local_dir, self.local_dir)
                self.exe_cmd(rm_cmd)
            elif c_type == 'release':
                print ("[WARNING] Not supported build type")
            elif c_type == 'debug':
                print ("[WARNING] Not supported build type")
            else:
                print ("[WARNING] Not supported build type")
        # finish shrink
        print ("[INFO] Shrink component finished")

#--------------------------------------------------------#
# move need component into matched platform binary path  #
#--------------------------------------------------------#

    def dist_component(self):
        binary_list = self.binary_parser()
        for binary_str in binary_list:
            install_path = '%s/../../output/dependency/%s/protobuf' % (self.local_dir, binary_str)
            comm_path = "%s/comm" % install_path
            llt_path = "%s/llt" % install_path
            if not os.path.exists(install_path):
                os.makedirs(comm_path)
                os.makedirs(llt_path)
            # move source code type
            for c_type in self.compiletype:
                if c_type == 'comm':
                    rm_cmd = 'rm -rf %s/comm; mkdir %s/comm' % (install_path, install_path)
                    self.exe_cmd(rm_cmd)
                    cp_cmd1 = 'cp -r %s/install_comm_dist/* %s/comm/' % (self.local_dir, install_path)
                    self.exe_cmd(cp_cmd1)
                elif c_type == 'llt':
                    rm_cmd = 'rm -rf %s/llt; mkdir %s/llt' % (install_path, install_path)
                    self.exe_cmd(rm_cmd)
                    cp_cmd1 = 'cp -r %s/install_llt_dist/* %s/llt/' % (self.local_dir, install_path)
                    self.exe_cmd(cp_cmd1)
                elif c_type == 'release':
                    print ("[WARNING] Not supported build type")
                elif c_type == 'debug':
                    print ("[WARNING] Not supported build type")
                else:
                    print ("[WARNING] Not supported build type")
        # finish dist
        print ("[INFO] Dist component finished")

#--------------------------------------------------------#
# clean component mode                                   #
#--------------------------------------------------------#

    def clean_component(self):
        source_code_path = self.folder_parser()
        # clean source code
        rm_cmd1 = 'cd %s; rm -rf install_comm_*; rm -rf install_llt_*;' % (self.local_dir)
        ret = self.exe_cmd(rm_cmd1)
        self.error_handler(ret)
        # finish clean
        print ("[INFO] Clean component finished")

#--------------------------------------------------------#
# base interface for executing command                   #
#--------------------------------------------------------#

    def exe_cmd(self, cmd):
        if sys.version_info < (3, 5):
            ret = subprocess.call(cmd, shell = True)
        else:
            run_tsk = subprocess.run(cmd, shell = True, check = True)
            ret = run_tsk.returncode
        return ret

#--------------------------------------------------------#
# build script operator parameter parser                 #
#--------------------------------------------------------#

def parse_args():
    parser = argparse.ArgumentParser(description='GaussDB Kernel open source software build script')
    
    parser.add_argument('-m', '--mode', type=str, required=True,
                        help='build mode set, all|build|shrink|dist|clean')
    parser.add_argument('-f', '--filename', type=str, required=True,
                        help='file name set')
    parser.add_argument('-t', '--compiletype', type=str, required=True,
                        help='compile type set "comm|llt|release|debug"')
    return parser.parse_args()

#--------------------------------------------------------#
# main function                                          #
#--------------------------------------------------------#

if __name__ == '__main__':
    tempath = os.path.dirname(os.path.realpath(__file__))
    status,output = subprocess.getstatusoutput("rm -rf " + tempath + "/install_*")
    args = parse_args()
    Operator = OPOperator(mode = args.mode, filename = args.filename, compiletype = args.compiletype)
    Operator.build_mode()

