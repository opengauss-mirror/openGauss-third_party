open source target name ：parquet
source code repository : product warehouse
compile dependency: boost, zlib, thritf, lz4, double-conbersion, brotli, snappy, zstd, glog, flatbuffers, rapodjson
upgrade open source package method：
----|pull command : python $(pwd)../../build/pull_open_source.py "path" "name" "id"
      |----path : the parent directory name
      |----name：the package name in product warehouse
      |----id：pdm version id
the compile command : 
Patch Info: 