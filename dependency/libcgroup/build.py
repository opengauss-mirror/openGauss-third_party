#!/usr/bin/env python
# coding=utf-8
# description: Python script for open source software build.
# Copyright (c) 2020 Huawei Technologies Co.,Ltd.
# date: 2020-06-08

import os
import subprocess
import sys
import argparse

#--------------------------------------------------------#
# open source software build operator                    #
#--------------------------------------------------------#

class OPOperator():
    def __init__(self, mode, filename, compiletype):
        self.mode = mode
        self.filename = filename
        self.local_dir = os.getcwd()
        self.compiletype = compiletype.split('|')

#--------------------------------------------------------#
# parser build source code folder parameter              #
#--------------------------------------------------------#

    def folder_parser(self):
        ls_cmd = 'cd %s; ls ' % (self.local_dir)
        file_str = os.popen(ls_cmd).read()
        file_list = file_str.split('\n')
        for pre_str in file_list:
            if pre_str.find('.tar.bz2') != -1:
                source_code = pre_str.split(".tar", 1)
                break
        print(source_code[0])
        return source_code[0]

#--------------------------------------------------------#
# parser build patch parameter                           #
#--------------------------------------------------------#

    def patch_parser(self):
        patch_list = []
        ls_cmd = 'cd %s; ls ' % (self.local_dir)
        file_str = os.popen(ls_cmd).read()
        file_list = file_str.split('\n')
        for pre_str in file_list:
            if pre_str.find('patch') != -1:
                patch_list.append(pre_str)
        return patch_list

#--------------------------------------------------------#
# parser binary libs parameter                           #
#--------------------------------------------------------#

    def binary_parser(self):
        binary_list = []
        platform_cmd = 'sh %s/../../build/get_PlatForm_str.sh' % (self.local_dir)
        platform_list = os.popen(platform_cmd).read().split('\n')
        platform_str = platform_list[0]
        if platform_str == 'euleros2.0_sp5_x86_64':
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
            print("[ERROR] Invalid return code(%d), exited" %(ret))
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
        rpm_cmd = 'cd %s; rpm2cpio %s | cpio -div' % (self.local_dir, self.filename)
        ret = self.exe_cmd(rpm_cmd)
        self.error_handler(ret)
        source_code_path = self.folder_parser()
        # tar open source package
        tar_file='%s.tar.bz2' % (source_code_path)
        tar_cmd = 'cd %s; tar -xvf %s' % (self.local_dir, tar_file)
        ret = self.exe_cmd(tar_cmd)
        self.error_handler(ret)
        # compile source code type
        for c_type in self.compiletype:
            if c_type == 'comm':
                prepare_cmd = 'rm -rf %s/install_comm; mkdir -p %s/install_comm' % (self.local_dir, self.local_dir)
                ret = self.exe_cmd(prepare_cmd)
                self.error_handler(ret)
                config_cmd = 'cd %s/%s; ./configure CFLAGS="-fstack-protector-all -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fPIC" --enable-static=no --enable-shared=yes --prefix=%s/install_comm' % (self.local_dir, source_code_path, self.local_dir)
                ret = self.exe_cmd(config_cmd)
                self.error_handler(ret)
                make_cmd = 'cd %s/%s; make -j4 && make install' % (self.local_dir, source_code_path)
                ret = self.exe_cmd(make_cmd)
                self.error_handler(ret)
                cp_cmd = 'cd %s/%s; make clean' % (self.local_dir, source_code_path)
                ret = self.exe_cmd(cp_cmd)
                self.error_handler(ret)
            elif c_type == 'llt':
                prepare_cmd = 'rm -rf %s/install_comm; mkdir -p %s/install_comm' % (self.local_dir, self.local_dir)
                ret = self.exe_cmd(prepare_cmd)
                self.error_handler(ret)
                config_cmd = 'cd %s/%s; ./configure CFLAGS="-fstack-protector-all -Wl,-z,relro,-z,now -Wl,-z,noexecstack -fPIC" --enable-static=no --enable-shared=yes --prefix=%s/install_comm' % (self.local_dir, source_code_path, self.local_dir)
                ret = self.exe_cmd(config_cmd)
                self.error_handler(ret)
                make_cmd = 'cd %s/%s; make -j4 && make install' % (self.local_dir, source_code_path)
                ret = self.exe_cmd(make_cmd)
                self.error_handler(ret)
                cp_cmd = 'cd %s/%s; make clean' % (self.local_dir, source_code_path)
                ret = self.exe_cmd(cp_cmd)
                self.error_handler(ret)
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
                self.error_handler(ret)
            elif c_type == 'llt':
                install_dist_cmd2 = 'mkdir -p %s/install_llt_dist' % (self.local_dir)
                ret = self.exe_cmd(install_dist_cmd2)
                self.error_handler(ret)
                cp_cmd2 = 'cp -r %s/install_comm/* %s/install_llt_dist' % (self.local_dir, self.local_dir)
                self.exe_cmd(cp_cmd2)
                self.error_handler(ret)
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
            install_path = '%s/../../output/dependency/%s/libcgroup' % (self.local_dir, binary_str)
            # move source code type
            for c_type in self.compiletype:
                if c_type == 'comm':
                    #rm_cmd = 'rm -rf %s/comm/*' % (install_path)
                    rm_cmd = 'rm -rf %s/comm; mkdir -p %s/comm' % (install_path, install_path)  
                    self.exe_cmd(rm_cmd)
                    cp_cmd1 = 'cp -r %s/install_comm_dist/* %s/comm/' % (self.local_dir, install_path)
                    self.exe_cmd(cp_cmd1)
                elif c_type == 'llt':
                    #rm_cmd1 = 'rm -rf %s/llt/*' % (install_path)
                    rm_cmd1 = 'rm -rf %s/llt; mkdir -p %s/llt' % (install_path, install_path)
                    self.exe_cmd(rm_cmd1)
                    cp_cmd2 = 'cp -r %s/install_llt_dist/* %s/llt/' % (self.local_dir, install_path)
                    self.exe_cmd(cp_cmd2)
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
        clean_cmd = 'cd %s/%s; make clean' % (self.local_dir, source_code_path)
        ret = self.exe_cmd(clean_cmd)
        self.error_handler(ret)
        rm_cmd = 'cd %s; rm -rf %s; rm -rf install_*' % (self.local_dir, source_code_path)
        ret = self.exe_cmd(rm_cmd)
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
    args = parse_args()
    Operator = OPOperator(mode = args.mode, filename = args.filename, compiletype = args.compiletype)
    cmd_str='python $(pwd)/../../build/pull_open_source.py "libcgroup" "libcgroup-0.41-21.el7.src.rpm" "05833VLC"'
    print("cwd is :",os.getcwd())
    ret=Operator.exe_cmd(cmd_str)
    print("ret is :",ret)
    Operator.build_mode()
