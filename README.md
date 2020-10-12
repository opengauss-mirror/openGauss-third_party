Hello openGauss-third_party

This repository is used to placed all opensource softwares depended by openGauss-server.

It will be used as submodule in the openGauss-server repository. 

These opensource files are processed by following ways:
    1. code reference directly, such as masstree
    2. build to generate dynamic or staic library.

There are four directories, 
    a. build directory includes scripts that can build all of the third-party that we depend on.
    b. buildtools includes the build tools used to compile these opensources and openGauss-server.
    c. dependency includes all depended opensource files of openGauss-server.
    d. platform includes the opensource software from Huawei company.

See the following command to build opensources to generate binarylibs directory
which is used when building openGauss-server.
We assume that you already have autoconf, gcc, gcc-c++ installed.
Before you build our binarylibs, the following is required:
```
libaio-devel
ncurses-devel
pam-devel
libffi-devel
python3-devel
libtool
```
Also, gcc 8.2.0 source code is needed, which shoud be put in buildtools/gcc/, whose file name may be gcc-8.2.0.tar.gz or gcc-8.2.0.zip,
consider downloading it from [gcc-8.2.0.zip](https://github.com/gcc-mirror/gcc/archive/releases/gcc-8.2.0.zip) or [gcc-8.2.0.tar.gz](https://github.com/gcc-mirror/gcc/archive/releases/gcc-8.2.0.tar.gz)
After all of above, you should change default python version to python3.x.
For generating all of binarylibs in one steps:
```
cd build
sh build_all.sh
```
To generate one of buildtools, dependency or platform
```
cd module/build
sh build.sh
```
To generate binarylibs which you want as:
```
cd dependency/${module}
sh build.sh -m all
```
The binarylibs will be installed on the same directory of openGauss-third_party, which name is binarylibs.
If some components build fail, you can check logs in:
```
openGauss-third_party/build
openGauss-third_party/$module/build
openGauss-third_party/$module/$components
```
And in order to continue compile remaining components, you can comment components which already compiled successfully in:
```
openGauss-third_party/buildtools/build/build_buildtools.sh
openGauss-third_party/dependency/build/build_dependency.sh
openGauss-third_party/platform/build/build_platform.sh
```