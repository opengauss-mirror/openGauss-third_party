open source target name ��nanomsg
source code repository : product warehouse
compile dependency: NULL
upgrade open source package method��
----|pull command : python $(pwd)../../build/pull_open_source.py "path" "name" "id"
      |----path : the parent directory name
      |----name��the package name in product warehouse
      |----id��pdm version id
the compile command : python build.py -m all -f nanomsg-1.1.5.tar.gz -t "comm"
Patch Info: 