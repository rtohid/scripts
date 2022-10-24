#!/bin/bash

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

OMP_DIR=${PREFIX}/openmp
BUILD_TYPE=Debug

HPX_DIR=${PREFIX}/hpx/cmake-install/${BUILD_TYPE}/lib/cmake/HPX

mkdir -p ${PREFIX}
if [ ! -d ${OMP_DIR} ]; then
  git clone --depth=1 https://github.com/llvm-mirror/openmp.git ${OMP_DIR}
fi

cd ${OMP_DIR}
cmake                                                                     \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                                        \
  -DCMAKE_VERBOSE_MAKEFILE=ON                                             \
  -DHPX_DIR=${HPX_DIR}                                                    \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                                      \
  -DCMAKE_CXX_FLAGS="-std=c++17"                                          \
  -DCMAKE_CXX_COMPILER=clang++                                            \
  -DCMAKE_C_COMPILER=clang                                                \
  -Wdev -S ${OMP_DIR} -B ${OMP_DIR}/cmake-build/${BUILD_TYPE}

cmake --build ${OMP_DIR}/cmake-build/${BUILD_TYPE}/ --parallel
cmake --install ${OMP_DIR}/cmake-build/${BUILD_TYPE}/ --prefix ${OMP_DIR}/cmake-install/${BUILD_TYPE}

