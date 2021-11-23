#!/bin/bash

PREFIX=/work/${USER}/halide_phylanx
BUILD_TYPE=Release

mkdir -p $PREFIX && cd $PREFIX

module load python/3.8.9

git clone git@github.com:STEllAR-GROUP/hpx.git

git clone git@github.com:STEllAR-GROUP/phylanx.git
git clone https://github.com/pybind/pybind11.git
git clone https://bitbucket.org/blaze-lib/blaze.git
git clone https://github.com/STEllAR-GROUP/blaze_tensor.git

git clone git@github.com:halide/Halide.git
git clone https://github.com/STEllAR-GROUP/phylanx_halide.git


# Build HPX
cd $PREFIX/hpx
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_CXX_FLAGS="-std=c++17" \
      -DHPX_WITH_THREAD_IDLE_RATES=ON \
      -DHPX_WITH_MALLOC=tcmalloc \
      -DHPX_WITH_EXAMPLES=OFF \
      -DAPEX_WITH_OTF2=ON \
      -DHPX_WITH_APEX=ON \
      -DHPX_WITH_FETCH_ASIO=ON \
      -Wdev -S . -B cmake-build/$BUILD_TYPE

cmake --build cmake-build/$BUILD_TYPE/ --parallel 
cmake --install cmake-build/$BUILD_TYPE/ --prefix cmake-install/$BUILD_TYPE

# Build Blaze
cd $PREFIX/blaze
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_CXX_FLAGS="-std=c++17" \
      -DBLAZE_SMP_THREADS=HPX \
      -DHPX_DIR=$PREFIX/hpx/cmake-install/$BUILD_TYPE/lib64/cmake/HPX \
      -S . -B cmake-build/$BUILD_TYPE

cmake --build cmake-build/$BUILD_TYPE/ --parallel 
cmake --install cmake-build/$BUILD_TYPE/ --prefix cmake-install/$BUILD_TYPE


# Build Blaze Tensor
cd $PREFIX/blaze_tensor
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_CXX_FLAGS="-std=c++17" \
      -Dblaze_DIR=$PREFIX/blaze/cmake-install/$BUILD_TYPE/share/blaze/cmake \
      -DHPX_DIR=$PREFIX/hpx/cmake-install/$BUILD_TYPE/lib64/cmake/HPX \
      -S . -B cmake-build/$BUILD_TYPE

cmake --build cmake-build/$BUILD_TYPE/ --parallel 
cmake --install cmake-build/$BUILD_TYPE/ --prefix cmake-install/$BUILD_TYPE


# Blaze pybind11
cd $PREFIX/pybind11
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
	-DCMAKE_CXX_FLAGS="-std=c++17" \
	-DPYTHON_EXECUTABLE:FILEPATH=python3.8 \
	-S . -B cmake-build/$BUILD_TYPE

cmake --build cmake-build/$BUILD_TYPE/ --parallel 
cmake --install cmake-build/$BUILD_TYPE/ --prefix cmake-install/$BUILD_TYPE


# Build Phylanx
cd $PREFIX/phylanx
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_CXX_FLAGS="-std=c++17" \
      -Dpybind11_DIR=$PREFIX/pybind11/cmake-install/$BUILD_TYPE/share/cmake/pybind11 \
      -Dblaze_DIR=$PREFIX/blaze/cmake-install/$BUILD_TYPE/share/blaze/cmake \
      -DBlazeTensor_DIR=$PREFIX/blaze_tensor/cmake-install/$BUILD_TYPE/share/blaze_tensor/cmake \
      -DHPX_WITH_MALLOC=tcmalloc \
      -DHPX_DIR=$PREFIX/hpx/cmake-install/$BUILD_TYPE/lib64/cmake/HPX/ \
      -DPHYLANX_WITH_VIM_YCM=ON \
      -DPYTHON_EXECUTABLE:FILEPATH=python3.8 \
      -Wdev -S . -B cmake-build/$BUILD_TYPE

cmake --build cmake-build/$BUILD_TYPE/ --parallel 12
cmake --install cmake-build/$BUILD_TYPE/ --prefix cmake-install/$BUILD_TYPE



# Build Halide
cd $PREFIX/Halide/
git checkout  v12.0.1
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
      -DCMAKE_CXX_FLAGS="-std=c++17" \
      -S . -B cmake-build/$BUILD_TYPE

cmake --build cmake-build/$BUILD_TYPE/ --parallel 
cmake --install cmake-build/$BUILD_TYPE/ --prefix cmake-install/$BUILD_TYPE


# Build Halide Plugin
cd $PREFIX/phylanx_halide/
git checkout halide-blas
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_CXX_FLAGS="-std=c++17" \
      -DCMAKE_PREFIX_PATH="$PREFIX/hpx/cmake-install/$BUILD_TYPE/lib64/cmake/HPX/;$PREFIX/Halide/cmake-install/$BUILD_TYPE/lib64/cmake/HalideHelpers/;$PREFIX/Halide/cmake-install/$BUILD_TYPE/lib64/cmake/Halide" \
	-DPhylanx_DIR=$PREFIX/phylanx/cmake-build/$BUILD_TYPE/lib/cmake/Phylanx/ \
	-S . -B cmake-build/$BUILD_TYPE

cmake --build cmake-build/$BUILD_TYPE/ --parallel
cmake --install cmake-build/$BUILD_TYPE/ --prefix cmake-install/$BUILD_TYPE

