open source target name ��thrift
source code repository : product warehouse
compile dependency: openssl, boost
upgrade open source package method��
----|pull command : python $(pwd)../../build/pull_open_source.py "path" "name" "id"
      |----path : the parent directory name
      |----name��the package name in product warehouse
      |----id��pdm version id
the compile command : sh ./build.sh
Patch Info: 