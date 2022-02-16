git clone --depth 1 https://github.com/STEllAR-GROUP/hpx.git
cd hpx
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DHPX_WITH_EXAMPLES=Off -DCMAKE_INSTALL_PREFIX:PATH=${HOME}/local/release/hpx -DHPX_WITH_MALLOC=tcmalloc -DTCMALLOC_ROOT=${HOME}/local/release/gperftools/ -DHPX_WITH_DEPRECATION_WARNINGS=Off ..
make -j 16
make install

