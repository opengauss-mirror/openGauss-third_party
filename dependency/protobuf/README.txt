open source target name ��protobuf
source code repository : product warehouse
compile dependency: NUL
upgrade open source package method��
----|pull command : python $(pwd)../../build/pull_open_source.py "path" "name" "id"
      |----path : the parent directory name
      |----name��the package name in product warehouse
      |----id��pdm version id
the compile command : python build.py -m all -f protobuf-3.11.3.zip -t "comm|llt"
Patch Info: 
