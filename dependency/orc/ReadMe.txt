open source target name £ºorc
source code repository : product warehouse
compile dependency: zlib, lz4, snappy, protobuf
upgrade open source package method£º
----|pull command : python $(pwd)../../build/pull_open_source.py "path" "name" "id"
      |----path : the parent directory name
      |----name£ºthe package name in product warehouse
      |----id£ºpdm version id
the compile command : sh ./build.sh
Patch Info: 
