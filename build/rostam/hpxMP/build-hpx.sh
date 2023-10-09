#!/bin/bash

module load gcc/12.3.0 boost

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

BUILD_TYPE=Debug
HPX_DIR=${PREFIX}/hpx/


mkdir -p ${PREFIX}

git clone git@github.com:STEllAR-GROUP/hpx.git ${HPX_DIR}

cd ${HPX_DIR}
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE}               \
      -DCMAKE_CXX_FLAGS="-std=c++17"                 \
      -DCMAKE_CXX_COMPILER=g++                       \
      -DHPX_WITH_THREAD_IDLE_RATES=ON                \
      -DHPX_WITH_MALLOC=tcmalloc                     \
      -DHPX_WITH_EXAMPLES=OFF                        \
      -DHPX_WITH_FETCH_APEX=ON                       \
      -DHPX_WITH_FETCH_ASIO=ON                       \
      -DHPX_WITH_DYNAMIC_HPX_MAIN=OFF                \
      -Wdev -S ${HPX_DIR} -B ${HPX_DIR}/cmake-build/${BUILD_TYPE}

cmake --build ${HPX_DIR}/cmake-build/${BUILD_TYPE}/ --parallel 
cmake --install ${HPX_DIR}/cmake-build/${BUILD_TYPE}/ --prefix ${HPX_DIR}/cmake-install/${BUILD_TYPE}

