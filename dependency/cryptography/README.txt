open source target name : cryptography
source code repository : product warehouse
compile dependency: asn1crypto, ipaddress, enum34, openssl, cffi, six
upgrade open source package method��
----|pull command : python $(pwd)../../build/pull_open_source.py "path" "name" "id"
      |----path : the parent directory name
      |----name��the package name in product warehouse
      |----id��pdm version id
the compile command : sh ./build.sh
Patch Info: 