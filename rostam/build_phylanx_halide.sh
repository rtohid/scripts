#!/bin/bash

mkdir /work/rtohid/p3hpc && cd /work/rtohid/p3hpc

git clone git@github.com:STEllAR-GROUP/hpx.git

git clone git@github.com:STEllAR-GROUP/phylanx.git
git clone https://github.com/pybind/pybind11.git
git clone https://bitbucket.org/blaze-lib/blaze.git
git clone https://github.com/STEllAR-GROUP/blaze_tensor.git

git clone git@github.com:halide/Halide.git
git clone https://github.com/STEllAR-GROUP/phylanx_halide.git


# Build HPX
cd /work/rtohid/p3hpc/hpx
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-std=c++17" -DHPX_WITH_THREAD_IDLE_RATES=ON -DHPX_WITH_MALLOC=tcmalloc -DHPX_WITH_EXAMPLES=OFF -DAPEX_WITH_OTF2=ON -DHPX_WITH_APEX=ON -DHPX_WITH_FETCH_ASIO=ON  -Wdev -S . -B cmake-build-release

cmake --build cmake-build-release/ --parallel 
cmake --install cmake-build-release/ --prefix cmake-install-release

# Build Blaze
cd /work/rtohid/p3hpc/blaze
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-std=c++17" -DBLAZE_SMP_THREADS=HPX -DHPX_DIR=/work/rtohid/p3hpc/hpx/cmake-install-release/lib64/cmake/HPX  -S . -B cmake-build-release

cmake --build cmake-build-release/ --parallel 
cmake --install cmake-build-release/ --prefix cmake-install-release


# Build Blaze Tensor
cd /work/rtohid/p3hpc/blaze_tensor
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-std=c++17" -Dblaze_DIR=/work/rtohid/p3hpc/blaze/cmake-install-release/share/blaze/cmake -DHPX_DIR=/work/rtohid/p3hpc/hpx/cmake-install-release/lib64/cmake/HPX -S . -B cmake-build-release

cmake --build cmake-build-release/ --parallel 
cmake --install cmake-build-release/ --prefix cmake-install-release


# Blaze pybind11
cd /work/rtohid/p3hpc/pybind11
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-std=c++17" -DPYTHON_EXECUTABLE:FILEPATH=python3.6 -S . -B cmake-build-release

cmake --build cmake-build-release/ --parallel 
cmake --install cmake-build-release/ --prefix cmake-install-release


# Build Phylanx
cd /work/rtohid/p3hpc/phylanx
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-std=c++17" \
	-Dpybind11_DIR=/work/rtohid/p3hpc/pybind11/cmake-install-release/share/cmake/pybind11 \
	-Dblaze_DIR=/work/rtohid/p3hpc/blaze/cmake-install-release/share/blaze/cmake \
	-DBlazeTensor_DIR=/work/rtohid/p3hpc/blaze_tensor/cmake-install-release/share/blaze_tensor/cmake \
	-DPHYLANX_WITH_EXAMPLES=OFF \
	-DHPX_WITH_MALLOC=tcmalloc \
	-DHPX_DIR=/work/rtohid/p3hpc/hpx/cmake-install-release/lib64/cmake/HPX/ \
	-DPHYLANX_WITH_VIM_YCM=ON \
	-DPYTHON_EXECUTABLE:FILEPATH=python3.6 \
	-Wdev \
	-S . -B cmake-build-release

cmake --build cmake-build-release/ --parallel 12
cmake --install cmake-build-release/ --prefix cmake-install-release



# Build Halide
cd /work/rtohid/p3hpc/Halide/
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-std=c++17" -DCMAKE_TOOLCHAIN_FILE=/work/rtohid/vcpkg/scripts/buildsystems/vcpkg.cmake -S . -B cmake-build-release

cmake --build cmake-build-release/ --parallel 
cmake --install cmake-build-release/ --prefix cmake-install-release


# Build Halide Plugin
cd /work/rtohid/p3hpc/phylanx_halide/
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-std=c++17" \
	-DCMAKE_PREFIX_PATH="/work/rtohid/p3hpc/hpx/cmake-install-release/lib64/cmake/HPX/;/work/rtohid/p3hpc/Halide/cmake-install-release/lib64/cmake/HalideHelpers/;/work/rtohid/p3hpc/Halide/cmake-install-release/lib64/cmake/Halide" \
	-DPhylanx_DIR=/work/rtohid/p3hpc/phylanx/cmake-build-release/lib/cmake/Phylanx/ \
	-S . -B cmake-build-release

cmake --build cmake-build-release/ --parallel
cmake --install cmake-build-release/ --prefix cmake-install-release

