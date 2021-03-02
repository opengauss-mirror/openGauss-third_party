files="libasan.a  liblsan.a  libtsan.a  libubsan.a"
rm ./lib/*
for f in $files
do
	echo "fetching $f"
	cp ../../../../open_source/gcc/install_comm/lib64/$f ./lib
done
