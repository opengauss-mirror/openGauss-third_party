#!/usr/bin/env python
# coding=utf-8
# description: Python script for open source software build.
# Copyright (c) 2020 Huawei Technologies Co.,Ltd.
# date: 2020-06-08

import os
import subprocess
import sys
import argparse
import commands

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
            binary_list.append('euleros2.0_sp8_aarch64')
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
        # download source package
        download_cmd = 'python $(pwd)/../../build/pull_open_source.py "jemalloc" "jemalloc-5.2.1.tar.gz" "05833NWG"'
        ret = self.exe_cmd(download_cmd)
        self.error_handler(ret)
        # unzip source code
        source_code_path = self.folder_parser()
        uzip_cmd = 'cd %s; chmod u+x %s; tar zxvf %s' % (self.local_dir, self.filename, self.filename)
        ret = self.exe_cmd(uzip_cmd)
        self.error_handler(ret)
        # get cpu core num
        get_cpu_cmd = 'grep -w processor /proc/cpuinfo|wc -l'
        status, output = commands.getstatusoutput(get_cpu_cmd)
        self.error_handler(status)
        cpu_num = output.strip()
        # generate configure
        gen_cmd = 'cd %s/%s; sh autogen.sh' % (self.local_dir, source_code_path)
        ret = self.exe_cmd(gen_cmd)
        self.error_handler(ret)
        chd_cmd = 'cd %s/%s; chmod +x configure' % (self.local_dir, source_code_path)
        ret = self.exe_cmd(chd_cmd)
        self.error_handler(ret)
        # compile source code type
        for c_type in self.compiletype:
            if c_type == 'comm':
                print ("[WARNING] Not supported build type")
            elif c_type == 'llt':
                print ("[WARNING] Not supported build type")
            elif c_type == 'release':
                prepare_cmd = 'rm -rf %s/install_release; mkdir -p %s/install_release' % (self.local_dir, self.local_dir)
                ret = self.exe_cmd(prepare_cmd)
                self.error_handler(ret)
                config_cmd = 'cd %s/%s; ./configure CFLAGS=-fPIC CXXFLAGS=-fPIC --with-lg-page=16 --with-lg-hugepage=21 --with-malloc-conf="background_thread:true,dirty_decay_ms:0,muzzy_decay_ms:0,lg_extent_max_active_fit:2" --prefix=%s/install_release' % (self.local_dir, source_code_path, self.local_dir)
                ret = self.exe_cmd(config_cmd)
                self.error_handler(ret)
                make_cmd = 'cd %s/%s; make -j%s && make install ' % (self.local_dir, source_code_path, cpu_num)
                ret = self.exe_cmd(make_cmd)
                self.error_handler(ret)
            elif c_type == 'debug':
                prepare_cmd = 'rm -rf %s/install_debug; mkdir -p %s/install_debug' % (self.local_dir, self.local_dir)
                ret = self.exe_cmd(prepare_cmd)
                self.error_handler(ret)
                config_cmd = 'cd %s/%s; ./configure CFLAGS=-fPIC CXXFLAGS=-fPIC --with-lg-page=16 --with-lg-hugepage=21 --with-malloc-conf="background_thread:true,dirty_decay_ms:0,muzzy_decay_ms:0,lg_extent_max_active_fit:2" --enable-debug --enable-prof --prefix=%s/install_debug' % (self.local_dir, source_code_path, self.local_dir)
                ret = self.exe_cmd(config_cmd)
                self.error_handler(ret)
                make_cmd = 'cd %s/%s; make -j%s && make install ' % (self.local_dir, source_code_path, cpu_num)
                ret = self.exe_cmd(make_cmd)
                self.error_handler(ret)
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
                print ("[WARNING] Not supported build type")
            elif c_type == 'llt':
                print ("[WARNING] Not supported build type")
            elif c_type == 'release':
                install_dist_cmd = 'mkdir -p %s/install_release_dist' % (self.local_dir)
                ret = self.exe_cmd(install_dist_cmd)
                self.error_handler(ret)
                cp_cmd1 = 'cp -r %s/install_release/* %s/install_release_dist' % (self.local_dir, self.local_dir)
                self.exe_cmd(cp_cmd1)
                self.error_handler(ret)
                rm_cmd = 'rm -rf %s/install_release_dist/lib/libjemalloc.so*; rm -rf %s/install_release_dist/lib/libjemalloc_pic.a' % (self.local_dir, self.local_dir)
                self.exe_cmd(rm_cmd)
                self.error_handler(ret)
                install_dist_cmd1 = 'mkdir -p %s/install_release_llt_dist' % (self.local_dir)
                ret = self.exe_cmd(install_dist_cmd1)
                self.error_handler(ret)
                cp_cmd2 = 'cp -r %s/install_release/* %s/install_release_llt_dist' % (self.local_dir, self.local_dir)
                self.exe_cmd(cp_cmd2)
                self.error_handler(ret)
                rm_cmd1 = 'rm -rf %s/install_release_llt_dist/lib/libjemalloc.so*; rm -rf %s/install_release_llt_dist/lib/libjemalloc.a' % (self.local_dir, self.local_dir)
                self.exe_cmd(rm_cmd1)
                self.error_handler(ret)
            elif c_type == 'debug':
                debug_dist_cmd = 'mkdir -p %s/install_debug_dist' % (self.local_dir)
                ret = self.exe_cmd(debug_dist_cmd)
                self.error_handler(ret)
                cp_cmd1 = 'cp -r %s/install_debug/* %s/install_debug_dist' % (self.local_dir, self.local_dir)
                self.exe_cmd(cp_cmd1)
                self.error_handler(ret)
                rm_cmd = 'rm -rf %s/install_debug_dist/lib/libjemalloc.so*; rm -rf %s/install_debug_dist/lib/libjemalloc_pic.a' % (self.local_dir, self.local_dir)
                self.exe_cmd(rm_cmd)
                self.error_handler(ret)
                debug_dist_cmd1 = 'mkdir -p %s/install_debug_llt_dist' % (self.local_dir)
                ret = self.exe_cmd(debug_dist_cmd1)
                self.error_handler(ret)
                cp_cmd2 = 'cp -r %s/install_debug/* %s/install_debug_llt_dist' % (self.local_dir, self.local_dir)
                self.exe_cmd(cp_cmd2)
                self.error_handler(ret)
                rm_cmd1 = 'rm -rf %s/install_debug_llt_dist/lib/libjemalloc.so*; rm -rf %s/install_debug_llt_dist/lib/libjemalloc.a' % (self.local_dir, self.local_dir)
                self.exe_cmd(rm_cmd1)
                self.error_handler(ret)
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
            install_path = '%s/../../output/dependency/%s/jemalloc' % (self.local_dir, binary_str)
            # move source code type
            for c_type in self.compiletype:
                if c_type == 'comm':
                    print ("[WARNING] Not supported build type")
                elif c_type == 'llt':
                    print ("[WARNING] Not supported build type")
                elif c_type == 'release':
                    rm_cmd = 'rm -rf %s/release; mkdir -p %s/release' % (install_path, install_path)
                    self.exe_cmd(rm_cmd)
                    cp_cmd = 'cp -r %s/install_release_dist/* %s/release/' % (self.local_dir, install_path)
                    self.exe_cmd(cp_cmd)
                    rm_cmd1 = 'rm -rf %s/release_llt; mkdir -p %s/release_llt' % (install_path, install_path)
                    self.exe_cmd(rm_cmd1)
                    cp_cmd1 = 'cp -r %s/install_release_llt_dist/* %s/release_llt/' % (self.local_dir, install_path)
                    self.exe_cmd(cp_cmd1)
                elif c_type == 'debug':
                    rm_cmd = 'rm -rf %s/debug; mkdir -p %s/debug' % (install_path, install_path)
                    self.exe_cmd(rm_cmd)
                    cp_cmd = 'cp -r %s/install_debug_dist/* %s/debug/' % (self.local_dir, install_path)
                    self.exe_cmd(cp_cmd)
                    rm_cmd1 = 'rm -rf %s/debug_llt; mkdir -p %s/debug_llt' % (install_path, install_path)
                    self.exe_cmd(rm_cmd1)
                    cp_cmd1 = 'cp -r %s/install_debug_llt_dist/* %s/debug_llt/' % (self.local_dir, install_path)
                    self.exe_cmd(cp_cmd1)
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
    Operator.build_mode()

