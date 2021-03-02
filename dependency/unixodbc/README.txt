open source target name: unixodbc
source code repository: unixODBC-2.3.9.tar.gz
compile dependency: 
upgrade open source package method:
----|pull command: python $(pwd)../../build/pull_open_source.py "unixodbc" "unixODBC-2.3.9.tar.gz" "05836YTH"
      |----path: the parent directory name
      |----name: the package name in product warehouse
      |----id: pdm version id
the compile command: sh -x build.sh -m all
Patch Info:
backup:
tar xzf unixODBC-2.3.9
sh build.sh -m build
sh build.sh -m shrink
sh build.sh -m dist
