#!/usr/bin/env python
# coding=utf-8
# description: Python script for open source software build.
# Copyright (c) 2020 Huawei Technologies Co.,Ltd.
# date: 2020-09-01

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
            if pre_str.find('.tar.gz') != -1:
                source_code = pre_str.split(".tar.gz", 1)
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

    def error_handler(self, ret, cmd):
        if ret:
            print("[ERROR] Invalid return code(%d), exited, cmd is: %s" %(ret, cmd))
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
        # unzip source code
        source_code_path = self.folder_parser()
        uzip_cmd = 'cd %s; tar xvf %s' % (self.local_dir, self.filename)
        ret = self.exe_cmd(uzip_cmd)
        self.error_handler(ret, uzip_cmd)
        # compile source code type
        for c_type in self.compiletype:
            if c_type == 'release':
                print ("[WARNING] Not supported build type")
            elif c_type == 'llt':
                print ("[WARNING] Not supported build type")
            elif c_type == 'debug':
                print ("[WARNING] Not supported build type")
            elif c_type == 'comm':
                prepare_cmd = 'rm -rf %s/install_comm; mkdir -p %s/install_comm' % (self.local_dir, self.local_dir)
                ret = self.exe_cmd(prepare_cmd)
                self.error_handler(ret, prepare_cmd)
                delete_rpath_cmd1 = "cd %s/%s; sed -i 's/hardcode_libdir_flag_spec=\x27$wl-rpath,$libdir\x27/hardcode_libdir_flag_spec=/g' configure" % (self.local_dir, source_code_path)
                ret = self.exe_cmd(delete_rpath_cmd1)
                self.error_handler(ret, delete_rpath_cmd1)
                delete_rpath_cmd2 = "cd %s/%s; sed -i 's/$wl-rpath $wl$libdir//g' configure" % (self.local_dir, source_code_path)
                ret = self.exe_cmd(delete_rpath_cmd2)
                self.error_handler(ret, delete_rpath_cmd2)
                delete_rpath_cmd3 = "cd %s/%s; sed -i 's/runpath_var=\x27LD_RUN_PATH\x27/runpath_var=/g' configure" % (self.local_dir, source_code_path)
                ret = self.exe_cmd(delete_rpath_cmd3)
                self.error_handler(ret, delete_rpath_cmd3)
                delete_rpath_cmd4 = "cd %s/%s; sed -i 's/runpath_var=LD_RUN_PATH/runpath_var=/g' configure" % (self.local_dir, source_code_path)
                ret = self.exe_cmd(delete_rpath_cmd4)
                self.error_handler(ret, delete_rpath_cmd4)
                add_pie_cmd1 = "cd %s/%s; sed -i 's/iperf3_CFLAGS = -g/iperf3_CFLAGS = -g -fPIE/' src/Makefile.in" % (self.local_dir, source_code_path)
                ret = self.exe_cmd(add_pie_cmd1)
                self.error_handler(ret, add_pie_cmd1)
                add_pie_cmd2 = "cd %s/%s; sed -i 's/iperf3_LDFLAGS = -g/iperf3_LDFLAGS = -g -pie/' src/Makefile.in" % (self.local_dir, source_code_path)
                ret = self.exe_cmd(add_pie_cmd2)
                self.error_handler(ret, add_pie_cmd2)
                config_cmd = "cd %s/%s; ./configure --prefix=%s/install_comm CFLAGS='-fstack-protector-all' LDFLAGS='-Wl,-z,relro,-z,now -z,noexecstack'" % (self.local_dir, source_code_path, self.local_dir)
                ret = self.exe_cmd(config_cmd)
                self.error_handler(ret, config_cmd)
                make_cmd = 'cd %s/%s; make && make install ' % (self.local_dir, source_code_path)
                ret = self.exe_cmd(make_cmd)
                self.error_handler(ret, make_cmd)
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
            if c_type == 'release':
                print ("[WARNING] Not supported build type")
            elif c_type == 'llt':
                print ("[WARNING] Not supported build type")
            elif c_type == 'debug':
                print ("[WARNING] Not supported build type")
            elif c_type == 'comm':
                install_dist_cmd = 'mkdir -p %s/install_comm_dist' % (self.local_dir)
                ret = self.exe_cmd(install_dist_cmd)
                self.error_handler(ret, install_dist_cmd)
                cp_cmd1 = 'cp -r %s/install_comm/bin %s/install_comm_dist' % (self.local_dir, self.local_dir)
                ret = self.exe_cmd(cp_cmd1)
                self.error_handler(ret, cp_cmd1)
                cp_cmd2 = 'mkdir -p %s/install_comm_dist/lib; cp %s/install_comm/lib/libiperf.so.0.0.0 %s/install_comm_dist/lib/libiperf.so.0' %(self.local_dir, self.local_dir, self.local_dir)
                ret = self.exe_cmd(cp_cmd2)
                self.error_handler(ret, cp_cmd2)
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
            install_path = '%s/../../output/dependency/%s/iperf' % (self.local_dir, binary_str)
            # move source code type
            for c_type in self.compiletype:
                if c_type == 'release':
                    print ("[WARNING] Not supported build type")
                elif c_type == 'llt':
                    print ("[WARNING] Not supported build type")
                elif c_type == 'debug':
                    print ("[WARNING] Not supported build type")
                elif c_type == 'comm':
                    rm_cmd = 'rm -rf %s/comm; mkdir -p %s/comm' % (install_path, install_path)
                    ret = self.exe_cmd(rm_cmd)
                    self.error_handler(ret, rm_cmd)
                    cp_cmd = 'cp -r %s/install_comm_dist/* %s/comm/' % (self.local_dir, install_path)
                    ret = self.exe_cmd(cp_cmd)
                    self.error_handler(ret, cp_cmd)
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
        self.error_handler(ret, clean_cmd)
        rm_cmd = 'cd %s; rm -rf %s; rm -rf install_*' % (self.local_dir, source_code_path)
        ret = self.exe_cmd(rm_cmd)
        self.error_handler(ret, rm_cmd)
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
                        help='file name to compile')
    parser.add_argument('-t', '--compiletype', type=str, required=True,
                        help='compile type set "comm|llt|release|debug"')
    return parser.parse_args()

#--------------------------------------------------------#
# main function                                          #
#--------------------------------------------------------#

if __name__ == '__main__':
    args = parse_args()
    Operator = OPOperator(mode = args.mode, filename = args.filename, compiletype = args.compiletype)
    cmd_str='python $(pwd)/../../build/pull_open_source.py "iperf" "iperf-3.7.tar.gz" "05833PNC"'
    print("cwd is :",os.getcwd())
    ret=Operator.exe_cmd(cmd_str)
    print("ret is :",ret)
    Operator.build_mode()
