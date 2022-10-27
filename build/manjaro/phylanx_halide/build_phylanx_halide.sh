#!/bin/bash

PREFIX=/work/${USER}/phylanx_halide
BUILD_TYPE=Release

mkdir -p $PREFIX && cd $PREFIX

HPX_PATH=${PREFIX}/hpx
PHYLANX_PATH=${PREFIX}/phylanx
PHYLANX_HALIDE_PATH=${PREFIX}/phylanx_halide
HALIDE_PATH=${PREFIX}/Halide
BLAZE_PATH=${PREFIX}/blaze
BLAZE_TENSOR_PATH=${PREFIX}/blaze_tensor
PYBIND11_PATH=${PREFIX}/pybind11

HPX_CONFIG_PATH=${HPX_PATH}/cmake-install/$BUILD_TYPE/lib/cmake/HPX
BLAZE_CONFIG_PATH=${BLAZE_PATH}/cmake-install/${BUILD_TYPE}/share/blaze/cmake
BLAZE_TENSOR_CONFIG_PATH=${BLAZE_TENSOR_PATH}/cmake-install/$BUILD_TYPE/share/blaze_tensor/cmake \
PYBIND11_CONFIG_PATH=${PYBIND11_PATH}/cmake-install/$BUILD_TYPE/share/cmake/pybind11

##### Build HPX
cd ${PREFIX}
git clone git@github.com:STEllAR-GROUP/hpx.git
cd ${HPX_PATH}
git checkout -b phylanx_halide 0db6fc565c
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DHPX_WITH_CXX_STANDARD=17                     \
      -DCMAKE_CXX_COMPILER=clang++                   \
      -DHPX_WITH_THREAD_IDLE_RATES=ON                \
      -DHPX_WITH_MALLOC=tcmalloc                     \
      -DHPX_WITH_EXAMPLES=OFF                        \
      -DHPX_WITH_APEX=ON                             \
      -DHPX_WITH_FETCH_ASIO=ON                       \
      -DHPX_WITH_DYNAMIC_HPX_MAIN=OFF                \
      -Wdev -S ${HPX_PATH} -B ${HPX_PATH}/cmake-build/${BUILD_TYPE}
cmake --build ${HPX_PATH}/cmake-build/${BUILD_TYPE} --parallel 
cmake --install ${HPX_PATH}/cmake-build/${BUILD_TYPE} --prefix ${HPX_PATH}/cmake-install/${BUILD_TYPE}

##### Build Blaze
cd ${PREFIX}
git clone https://bitbucket.org/blaze-lib/blaze.git
cd ${PREFIX}/blaze
git checkout -b phylanx_halide 89ee9476df
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DCMAKE_CXX_COMPILER=clang++   \
      -DCMAKE_CXX_FLAGS="-std=c++17" \
      -DBLAZE_SMP_THREADS=HPX        \
      -DHPX_DIR=${HPX_CONFIG_PATH}   \
      -S ${BLAZE_PATH} -B ${BLAZE_PATH}/cmake-build/${BUILD_TYPE}
cmake --build ${BLAZE_PATH}/cmake-build/${BUILD_TYPE} --parallel 
cmake --install ${BLAZE_PATH}/cmake-build/${BUILD_TYPE} --prefix ${BLAZE_PATH}/cmake-install/${BUILD_TYPE}

##### Build Blaze Tensor
cd ${PREFIX}
git clone https://github.com/STEllAR-GROUP/blaze_tensor.git
cd $PREFIX/blaze_tensor
cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE   \
      -DCMAKE_CXX_COMPILER=clang++     \
      -DCMAKE_CXX_FLAGS="-std=c++17"   \
      -Dblaze_DIR=${BLAZE_CONFIG_PATH} \
      -DHPX_DIR=${HPX_CONFIG_PATH}     \
      -S ${BLAZE_TENSOR_PATH} -B ${BLAZE_TENSOR_PATH}/cmake-build/${BUILD_TYPE}
cmake --build ${BLAZE_TENSOR_PATH}/cmake-build/${BUILD_TYPE} --parallel 
cmake --install ${BLAZE_TENSOR_PATH}/cmake-build/${BUILD_TYPE} --prefix ${BLAZE_TENSOR_PATH}/cmake-install/${BUILD_TYPE}

##### Build Halide
cd ${PREFIX}
git clone git@github.com:halide/Halide.git
cd ${HALIDE_PATH}
git checkout -b phylanx_halide 085e11e0dc
git checkout  v12.0.1
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DCMAKE_CXX_COMPILER=clang++     \
      -DCMAKE_CXX_FLAGS="-std=c++17"   \
      -DHalide_SHARED_LLVM=YES         \
      -S ${HALIDE_PATH} -B ${HALIDE_PATH}/cmake-build/${BUILD_TYPE}

cmake --build ${HALIDE_PATH}/cmake-build/${BUILD_TYPE}/ --parallel 
cmake --install ${HALIDE_PATH}/cmake-build/${BUILD_TYPE}/ --prefix ${HALIDE_PATH}/cmake-install/${BUILD_TYPE}

##### Build pybind11
cd ${PREFIX}
git clone https://github.com/pybind/pybind11.git
cd ${PYBIND11_PATH}
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE}       \
      -DCMAKE_CXX_COMPILER=clang++           \
    	-DCMAKE_CXX_FLAGS="-std=c++17"         \
    	-DPYTHON_EXECUTABLE:FILEPATH=python3   \
    	-S ${PYBIND11_PATH} -B ${PYBIND11_PATH}/cmake-build/${BUILD_TYPE}

cmake --build ${PYBIND11_PATH}/cmake-build/${BUILD_TYPE}/ --parallel 
cmake --install ${PYBIND11_PATH}/cmake-build/${BUILD_TYPE}/ --prefix ${PYBIND11_PATH}/cmake-install/${BUILD_TYPE}

##### Build Phylanx
echo ${PYBIND11_CONFIG_PATH}
cd ${PREFIX}
git clone git@github.com:STEllAR-GROUP/phylanx.git
cd ${PHYLANX_PATH}
git checkout -b phylanx_halide 295b5f82cc
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE}              \
      -DCMAKE_CXX_COMPILER=clang++                  \
      -DCMAKE_CXX_FLAGS="-std=c++17"                \
      -Dpybind11_DIR=${PYBIND11_CONFIG_PATH}        \
      -Dblaze_DIR=${BLAZE_CONFIG_PATH}              \
      -DBlazeTensor_DIR=${BLAZE_TENSOR_CONFIG_PATH} \
      -DHPX_WITH_MALLOC=tcmalloc                    \
      -DHPX_DIR=${HPX_CONFIG_PATH}                  \
      -DPYTHON_EXECUTABLE:FILEPATH=python3          \
      -Wdev -S ${PHYLANX_PATH} -B ${PHYLANX_PATH}/cmake-build/${BUILD_TYPE}

cmake --build ${PHYLANX_PATH}/cmake-build/${BUILD_TYPE} --parallel 20
cmake --install ${PHYLANX_PATH}/cmake-build/${BUILD_TYPE}/ --prefix ${PHYLANX_PATH}/cmake-install/${BUILD_TYPE}


##### Build Halide Plugin
cd ${PREFIX}
git clone https://github.com/STEllAR-GROUP/phylanx_halide.git
cd ${PHYLANX_HALIDE_PATH}
git checkout halide-blas
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DCMAKE_CXX_COMPILER=clang++     \
      -DCMAKE_CXX_FLAGS="-std=c++17"   \
      -DCMAKE_PREFIX_PATH="${HPX_CONFIG_PATH};${PREFIX}/Halide/cmake-install/${BUILD_TYPE}/lib/cmake/HalideHelpers/;${PREFIX}/Halide/cmake-install/${BUILD_TYPE}/lib/cmake/Halide" \
      -DPhylanx_DIR=${PREFIX}/phylanx/cmake-build/${BUILD_TYPE}/lib/cmake/Phylanx/ \
      -S ${PHYLANX_HALIDE_PATH} -B cmake-build/${BUILD_TYPE}

cmake --build cmake-build/${BUILD_TYPE}/ --parallel
cmake --install cmake-build/${BUILD_TYPE}/ --prefix cmake-install/${BUILD_TYPE}

cp ${PREFIX}/phylanx_halide/cmake-build/${BUILD_TYPE}/halide/blas/libphylanx_* ${PREFIX}/phylanx/cmake-build/${BUILD_TYPE}/lib/phylanx/
# python3 $PREFIX/phylanx_halide/profiling/halide_dgemm.py 16 2048 --hpx:print-counter=/papi{locality#*/worker-thread#*}/PAPI_L2_DCM

