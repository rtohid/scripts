git clone --depth 1 https://github.com/pybind/pybind11.git
cd pybind11
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/Users/rtohid/local/release/pybind11 ..
make -j 16 install
