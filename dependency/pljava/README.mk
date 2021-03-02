####################################################################
## pljava的编译说明
###################################################################

### pljava编译步骤
1. pljava编译必须在执行configure和make install之后，因为里面需要使用configure生成的Makefile和utils/errcodes.h文件（注意，make install编译失败也没有关系，只需要保证utils/errcodes.h等文件生成了即可）
2. 执行git clean -xdf保证干净的源代码目录
3. 然后执行./build.sh -m all完成编译

### pljava编译策略
1. libpljava.so和pljava.jar是PLJAVA必须的两个组件，在完成gaussdb的编译以后，libpljava.so将存放于$GAUSSHOME/lib/libpljava.so，pljava.jar将存放于$GAUSSHOME/lib/postgresql/java/pljava.jar
2. udstools.py是针对云上DWS，使用gs_extend_library上传OBS中的jar包时必须使用的，因一般不会变更，因此udstools.py会预先编译好，存放在Code/binarylibs/xxxxx(当前平台)/pljava/下，同时通过git跟踪修改。
3. 因考虑到PLJAVA中的JAVA代码一般不会变更，且仅依赖于JDK构建工具，同时.jar也是跨平台的，因此pljava.jar会预先编译好，而不是每次编译gaussdb时都进行编译。预先编译好的pljava.jar会存放在Code/binarylibs/xxxxx(当前平台)/pljava/下，同时通过git跟踪修改。
4. 因考虑到PLJAVA中的C代码的编译依赖于内核代码，而内核代码会高频率改动，因此libpljava.so会随着gaussdb的编译每次进行编译

####################################################################
## pljava build.sh编译选项详解
####################################################################

### ./build.sh -m all
该命令等价于顺序执行如下命令：
 ./build.sh -m build
 ./build.sh -m shrink
 ./build.sh -m dist
 ./build.sh -m clean

### ./build.sh -m build
该命令主要用于从一个干净的库(源代码还处于压缩包状态)去编译pljava.jar和pljava.so，该命令的执行过程为：
1. 对源文件pljava_1.5.2_src.zip中的pljava-1_5_2.tar.gz进行解压
2. 使用huawei_pljava.patch对源打上patch，此时会得到udstools.py、patch后用于编译的pljava代码，以及用于编译的Makefile，
   并在打完patch以后进入到代码目录plajva-1.5.2中
3. 执行make -sj pljava，此时会按照如下步骤进行编译
-3.1 编译pljava-api.jar
-3.2 编译pljava.jar，pljava.jar依赖pljava-api.jar，必须pljava-api.jar编译完成才能够对pljava.jar进行编译，因为编译时需要使用pljava-api.jar中的函数，最后会将编译出来的jar包跟pljava-api.jar压缩在一起形成新的最终的pljava.jar
-3.3 然后利用javah命令对pljava.jar生成的.h文件，javah依赖3.2编译出的pljava/target/class目录下的.class文件
4. 执行make -sj all, 此时会按照如下步骤进行编译
-4.1 重复步骤3，但是没关系，Makefile会发现并没有新增修改，因此不会重复编译
-4.2 执行make pljava_so生成libpljava.so，libpljava.so依赖javah，即3.3所生成的.h头文件
-4.3 将编译出的libpljava.so放在pljava/target/libpljava.so下，然后放到lib目录中
5. 执行make，make跟make all是等价的，相当于也是重复执行，但是没关系，Makefile会发现没有新增修改，因此不会重复编译
   最后得到的有用文件为：
   ./pljava-1_5_2/udstools.py
   ./pljava-1_5_2/lib/libpljava.so
   ./pljava-1_5_2/pljava/target/pljava.jar

### ./build.sh -m shrink
该命令的作用是将有用的文件复制出来。
每个开源软件完成编译后，其有效文件都是存储在这自己目录下的install_comm_dist和install_llt_dist两个目录中。
其中install_llt_dist是用来支撑蝴蝶工具扫描的，install_comm_dist内则是最终使用的文件。
两者的编译选项可能存在不同。但是对PLJAVA来说，并未进行区分。
该命令的具体执行过程为：
1. 复制./pljava-1_5_2/lib/libpljava.so到install_comm_dist/lib和install_llt_dist/lib下
2. 复制./pljava-1_5_2/udstools.py和./pljava-1_5_2/pljava/target/pljava.jar到install_comm_dist/java和install_llt_dist/java下

### ./build.sh -m dist
该命令将install_comm_dist和install_llt_dist复制到当前平台的Code/binarylibs/xxxxx(当前平台)/pljava/下。
只有复制到Code/binarylibs/xxxxx(当前平台)/pljava/下，在编译gaussdb时才能使用上。

### ./build.sh -m clean
该命令用于清理。
将删除open_source/pljava下编译（包括临时）文件及log等，但不会清理放在Code/binarylibs/xxxxx(当前平台)/pljava/下的文件。

### ./build.sh -m only_so
该命令将只编译libpljava.so文件，并将其复制到Code/binarylibs/xxxxx(当前平台)/pljava/目录下。
它依赖于pljava-so/目录下源码文件，和pljava/target/javah-include下利用javah预先生成的.h文件。
它的具体执行步骤是：
1. 根据patch-mds5值判断是否需要重新打patch，如果需要则解压源文件并对源代码打patch
-1.1 判断是否存在tmp_id.dat文件，一旦编译过，那么就会存在tmp_id.dat文件，记录最后一次编译的patch的md5值
-1.2 如果1.1不存在，表示从未编译过；或文件存在，但里面的值与patch_ids.dat对比失败，则表示不是最新的patch，则重新打patch
2. 执行make pljava_so生成libpljava.so
3. 将libpljava.so复制到install_comm_dist/lib和install_llt_dist/lib
4. 将libpljava.so复制到Code/binarylibs/xxxxx(当前平台)/pljava/目录下

### ./build.sh -m patch_md5
该命令对huawei_pljava.patch生成md5并写入patch_ids.dat中

####################################################################
## 如何正确使用编译选项
####################################################################

### 何时使用./build.sh -m build
1. 首次编译PLJAVA，并希望保留patch后的代码进行再开发时
2. 修改了huawei_pljava.patch或升级替换JDK版本时，确保该命令可以正确编译并得到预期结果

### 何时使用./build.sh -m only_so
1. gaussdb在编译时会调用该命令去编译libpljava.so，用来保证如果内核代码变化，libpljava.so能够被正确的编译
2. 开发人员在对PLJAVA源码中的C代码进行开发过程中，需要多次对libpljava.so进行调试。
   此时我们假设我们已经执行过./build.sh -m build，并在编译后的C源码上进行修改，那么此时只需要对libpljava.so进行编译即可。
   编译后将libpljava.so拷贝到$GAUSSHOME/lib/libpljava.so下，重启集群即可测试新的libpljava.so了

### 何时使用./build.sh -m patch_md5
1. huawei_pljava.patch文件产生修改时（注意，PLJAVA代码变动时，需重新生成huawei_pljava.patch）

####################################################################
## 如何对PLJAVA进行开发
####################################################################
1. 执行git clean -xdf保证干净的源代码目录
2. 执行./build.sh -m build获取到打完patch后的最新的PLJAVA代码
3. 对最新的PLJAVA代码基础上进行开发
4. 开发完成后，应根据修改情况对代码仓中PLJAVA相关组件进行更新，请参考#哪些场景需要考虑PLJAVA编译问题

####################################################################
## 哪些场景需要考虑重新编译PLJAVA
####################################################################
### JDK升级
如果JDK版本进行了升级，则需要对PLJAVA进行重新编译。
目前编译pljava.jar所使用的是Code/buildtools/xxxxx(当前平台)/huaweijdk8/jdk1.8.0_262来进行编译，
为了保证pljava-so,pljava-api,pljava都可以单独编译，因此JAVA_HOME是硬编码到以下Makefile中（后续可以考虑改进）:
./pljava-1_5_2/Makefile
./pljava-1_5_2/pljava-so/Makefile
./pljava-1_5_2/pljava-api/Makefile
./pljava-1_5_2/pljava/Makefile

因此如果JDK版本进行了升级，则需要对PLJAVA进行重新编译。重新编译分为两种情况：

#### JDK为小版本升级，目录仍然为Code/buildtools/xxxxx(当前平台)/huaweijdk8/jdk1.8.0_262没变化
1. 执行git clean -xdf保证干净的源代码目录
2. 执行./build.sh -m all得到./install_comm_dist/java/pljava.jar
3. 将./install_comm_dist/java/pljava.jar拷贝到binarylibs的每个平台下
   即：Code/binarylibs/xxxxx(所有平台）/pljava/comm/java/pljava.jar
4. 将./install_llt_dist/java/pljava.jar拷贝到binarylibs的每个平台下
   即：Code/binarylibs/xxxxx(所有平台）/pljava/llt/java/pljava.jar
5. git add Code/binarylibs/xxxxx(所有平台)/pljava/*
6. git commit

#### JDK为大版本升级，目录已经变更为其他目录了
1. vi huawei_pljava.patch，搜索所有的JAVA_HOME，并将里面的路径（huaweijdk8/jdk1.8.0_262）修改为正确的路径，之后保存
2. 执行./build.sh -m patch_md5更新patch的md5值
3. 执行**JDK小版本升级**中的步骤1-4
4. git add Code/binarylibs/xxxxx(所有平台)/pljava/* huawei_pljava.patch patch_ids.dat
5. git commit

####################################################################
### PLJAVA中JAVA代码需变更
例如JDK进行大版本升级时，有可能PLJAVA中的JAVA代码存在兼容性问题需要适配，或者是因为版本上的某些整改等，
导致PLJAVA中的JAVA代码变化时，必须对PLJAVA进行重新编译
1. 如果开发过程中执行过编译，请清理掉所有的.class，.o以及javah编译出来的.h文件，它们一般会存放在各级的target目录下
2. 对修改后的pljava-1_5_2重命名为pljava-1_5_2-new（建议在其他目录也备份，因为很容易编译时误删）
3. 解压源文件，unzip pljava_1.5.2_src.zip && tar -xf pljava_1.5.2_src/pljava-1_5_2.tar.gz
4. 执行diff -ruN pljava-1_5_2 pljava-1_5_2-new > huawei_pljava.patch 生成新的patch文件
5. 执行./build.sh -m patch_md5更新patch的md5值
6. 执行**JDK小版本升级**中的步骤1-4
7. git add Code/binarylibs/xxxxx(所有平台)/pljava/* huawei_pljava.patch patch_ids.dat
8. git commit

### PLJAVA中C代码需变更
完成对pljava-so目录下的C代码的开发后，需要更新PLJAVA中的patch，以保证gaussdb编译时能够获得最新的libpljava.so
1. 执行**PLJAVA中JAVA代码需变更**的步骤1-5
2. git add huawei_pljava.patch patch_ids.dat
3. git commit

####################################################################
### PLJAVA中udstools.py变更
例如安全告警需要对udstools.py进行变更时，需要重新处理
1. 如果新的udstools.py的总行数未变化，则仅需要修改huawei_pljava.patch。
   vi huawei_pljava.patch，搜索udstools.py，在其中进行修改
2. 如果改动带来行数变化，则使用 diff -ruN udstools.py udstools.py-new，并将内容在huawei_pljava.patch中对应位置进行替换
3. 执行./build.sh -m patch_md5更新patch的md5值
4. 重命名新的udstools.py-new为udstools.py放置于binarylibs的每个平台下
   即：Code/binarylibs/xxxxx(所有平台）/pljava/comm/udstools.py和Code/binarylibs/xxxxx(所有平台）/pljava/llt/udstools.py
5. git add Code/binarylibs/xxxxx(所有平台)/pljava/* huawei_pljava.patch patch_ids.dat
6. git commit

####################################################################
### PLJAVA中Makefile变更
1. 如果新的Makefile的总行数未变化，则仅需要修改huawei_pljava.patch
   vi huawei_pljava.patch，搜索对应的Makefile，在其中进行修改
2. 如果改动带来行数变化，则使用 diff -ruN Makefile Makefile-new，并将内容在huawei_pljava.patch中对应位置进行替换
3. 执行./build.sh -m patch_md5更新patch的md5值
4. git add huawei_pljava.patch patch_ids.dat
5. git commit
