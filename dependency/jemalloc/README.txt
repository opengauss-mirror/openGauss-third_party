open source target name £ºjemalloc
source code repository : product warehouse
compile dependency: NULL
upgrade open source package method£º
----|pull command : python $(pwd)../../build/pull_open_source.py "path" "name" "id"
      |----path : the parent directory name
      |----name£ºthe package name in product warehouse
      |----id£ºpdm version id
the compile command : python build.py -m all -f jemalloc-5.2.1.zip -t "release|debug"
Patch Info: 