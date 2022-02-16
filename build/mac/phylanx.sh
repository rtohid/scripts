git clone --depth 1 https://github.com/STEllAR-GROUP/phylanx.git
cd phylanx
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/Users/rtohid/local/release/phylanx -DHPX_DIR=/Users/rtohid/local/release/hpx/lib/cmake/HPX/ -Dblaze_DIR=/Users/rtohid/local/release/blaze/share/blaze/cmake/ -Dpybind11_DIR=/Users/rtohid/local/release/pybind11/share/cmake/pybind11/ ..
make -j 16
make install
