#!/bin/bash

set -e

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

BUILD_TYPE=Debug
LLVM_DIR=${PREFIX}/llvm-project
LLVM_VERSION=14.0.6
OMP_DIR=${LLVM_DIR}/openmp
HPX_DIR=${PREFIX}/hpx/cmake-install/${BUILD_TYPE}/lib/cmake/HPX
HPXC_DIR=${PREFIX}/hpxc
PROJECT=hpxmp
LOG_FILE=${PREFIX}/logs/${PROJECT}-build-options.log

sh ${PREFIX}/build-hpxc.sh

mkdir -p ${PREFIX}

# Logging the configuration
CONFIG="cmake
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
  -DCMAKE_VERBOSE_MAKEFILE=ON
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  -DCMAKE_CXX_FLAGS="-std=c++17"
  -DCMAKE_CXX_COMPILER=clang++
  -DCMAKE_C_COMPILER=clang
  -DHPX_DIR=${HPX_DIR}
  -DWITH_HPXC=ON
  -DHPXC_DIR=${HPXC_DIR}
  -Wdev -S ${OMP_DIR} -B ${OMP_DIR}/cmake-build-${PROJECT}/${BUILD_TYPE}
  # -DKA_TRACE=ON

cmake --build ${OMP_DIR}/cmake-build-${PROJECT}/${BUILD_TYPE}/ --parallel
cmake --install ${OMP_DIR}/cmake-build-${PROJECT}/${BUILD_TYPE}/ --prefix ${OMP_DIR}/cmake-install-${PROJECT}/${BUILD_TYPE}
"

echo "${CONFIG}"

if [ ! -d ${LLVM_DIR} ]; then
  git clone --depth=1 -b hpxmp git@github.com:rtohid/llvm-project.git ${LLVM_DIR}
fi

cd ${OMP_DIR}
cmake                                \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}   \
  -DCMAKE_VERBOSE_MAKEFILE=ON        \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DCMAKE_CXX_FLAGS="-std=c++17"     \
  -DCMAKE_CXX_COMPILER=clang++       \
  -DCMAKE_C_COMPILER=clang           \
  -DHPX_DIR=${HPX_DIR}               \
  -DWITH_HPXC=ON                     \
  -DHPXC_DIR=${HPXC_DIR}             \
  -Wdev -S ${OMP_DIR} -B ${OMP_DIR}/cmake-build-${PROJECT}/${BUILD_TYPE}
  # -DKA_TRACE=ON                      \

cmake --build ${OMP_DIR}/cmake-build-${PROJECT}/${BUILD_TYPE}/ --parallel
cmake --install ${OMP_DIR}/cmake-build-${PROJECT}/${BUILD_TYPE}/ --prefix ${OMP_DIR}/cmake-install-${PROJECT}/${BUILD_TYPE}

# Writing the config to file.
mkdir -p logs
LOG="$(date); running $0 from $(pwd)" >> ${LOG_FILE}
LINE="~"
for i in $(seq 2 ${#LOG}); do
  LINE+="~"
done
echo ${LOG} >> ${LOG_FILE}
echo ${LINE} >> ${LOG_FILE}
echo "${CONFIG}" >> ${LOG_FILE}
echo >> ${LOG_FILE}

