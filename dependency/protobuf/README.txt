open source target name £ºprotobuf
source code repository : product warehouse
compile dependency: NUL
upgrade open source package method£º
----|pull command : python $(pwd)../../build/pull_open_source.py "path" "name" "id"
      |----path : the parent directory name
      |----name£ºthe package name in product warehouse
      |----id£ºpdm version id
the compile command : python build.py -m all -f protobuf-3.11.3.zip -t "comm|llt"
Patch Info: 
