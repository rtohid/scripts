git clone --depth 1 https://bitbucket.org/blaze-lib/blaze.git
cd blaze
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/Users/rtohid/local/release/blaze  -DBLAZE_SMP_THREADS=C++11 -DCMAKE_BUILD_TYPE=Release ..
make install
