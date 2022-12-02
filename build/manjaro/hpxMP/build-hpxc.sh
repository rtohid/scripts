#!/bin/bash

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

BUILD_TYPE=Debug
HPXC_DIR=${PREFIX}/hpxc
HPX_DIR=${PREFIX}/hpx/cmake-install/${BUILD_TYPE}/lib/cmake/HPX

mkdir -p ${PREFIX}

git clone git@github.com:STEllAR-GROUP/hpxc.git ${HPXC_DIR}

cmake                                               \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                  \
  -DHPX_DIR=${HPX_DIR}                              \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                \
  -DCMAKE_CXX_FLAGS="-std=c++17"                    \
  -DCMAKE_C_STANDARD=17                             \
  -DCMAKE_CXX_COMPILER=clang++                      \
  -DCMAKE_C_COMPILER=clang                          \
  -Wdev -S ${HPXC_DIR} -B ${HPXC_DIR}/cmake-build/${BUILD_TYPE}

cmake --build ${HPXC_DIR}/cmake-build/${BUILD_TYPE}/ --parallel 
cmake --install ${HPXC_DIR}/cmake-build/${BUILD_TYPE}/ --prefix ${HPXC_DIR}/cmake-install/${BUILD_TYPE}

