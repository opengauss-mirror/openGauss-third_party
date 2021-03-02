openGauss-third_party

这个仓库用来编译openGauss依赖的所有开源三方软件。

这些开源文件通过以下方式处理：
    1. 直接引用代码，例如masstree
    2. 生成动态或静态库。

有四个目录 \
    a、 build目录包括可以构建我们所依赖的所有第三方的脚本。 \
    b、 buildtools包括用于编译这些opensources和openGauss服务器的构建工具。\
    c、 dependency包括openGauss服务器的所有依赖的开源组件。\
    d、 platform包括openjdk等开源软件。

### 安装依赖

使用下面的步骤来构建开源软件的二进制目录，用来编译openGauss数据库。\
请确保在构建前，服务器已经安装了`gcc gcc-c++` \
开始编译二进制前，还需要下面这些依赖，可以通过yum install进行安装。

编译三方库中python相关组件依赖python3，请将 /usr/bin/python 链接到python3。
```
libaio-devel
ncurses-devel
pam-devel
libffi-devel
python3-devel
libtool
libtool-devel 
libtool-ltdl
python-devel
openssl-devel
bison
```

### 编译gcc和cmake

三方库编译还需要依赖gcc-7.3.0、cmake(版本大于3.16.5)。请先下载gcc [gcc-7.3.0.zip](https://github.com/gcc-mirror/gcc/archive/releases/gcc-7.3.0.zip) 或者 [gcc-7.3.0.tar.gz](https://github.com/gcc-mirror/gcc/archive/releases/gcc-7.3.0.tar.gz)，以及cmake (https://cmake.org/download/#latest) 并解压后编译。

编译完成后，将gcc7.3和cmake导入到环境变量中（下一步的三方库编译依赖这两个），例如：

```
export CMAKEROOT=/usr/local/cmake3.18
export GCC_PATH=/opt/gcc/gcc7.3
export CC=$GCC_PATH/gcc/bin/gcc
export CXX=$GCC_PATH/gcc/bin/g++
export LD_LIBRARY_PATH=$GCC_PATH/gcc/lib64:$GCC_PATH/isl/lib:$GCC_PATH/mpc/lib/:$GCC_PATH/mpfr/lib/:$GCC_PATH/gmp/lib/:$CMAKEROOT/lib:$LD_LIBRARY_PATH
export PATH=$GCC_PATH/gcc/bin:$CMAKEROOT/bin:$PATH
```

### 编译三方库

进入到`openGauss-third_party/build` 目录下，执行`sh build_all.sh`，编译全量的三方组件。 

build_all.sh中先编译了openssl，然后编译buildtools, platform 和 dependency，可以对这三个按顺序分别编译:

***build tools***
```
cd openGauss-third_party/build_tools
sh build_tools.sh
```

***build platform***
```
cd openGauss-third_party/platform/build/
sh build_platform.sh
```

***build dependency***
```
cd openGauss-third_party/dependency/build/
sh build_dependency.sh
```

### openEuler系统编译Python3

由于openEuler系统上openssl版本与openGauss三方库中版本不一致导致的兼容性问题，在使用OM安装，建立互信时候会出现错误。在openEuler上编译三方库完成后还需要编译下Python3。
操作如下：
```
cd openGauss-third_party/build_tools/python3
sh build.sh
```

### 编译完成

编译完成后，编译结果在`openGauss-third_party/output`目录下。 \
还需要在`openGauss-third_party/output/buildtools/` 下，创建该平台目录，并将编译好的gcc7.3拷贝到该目录下。 \
创建的平台目录获取方式：`sh ./build/get_PlatForm_str.sh`。
以在x86平台上centos为例，gcc7.3的路径为：`output/buildtools/centos7.6_x86_64/gcc7.3`

以上步骤完成后，`openGauss-third_party/output`目录就是完整的三方库二进制。可以用来进行数据库编译。