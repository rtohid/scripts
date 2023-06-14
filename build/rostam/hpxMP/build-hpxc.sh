#!/bin/bash

module load gcc/12.3.0 boost

set -e

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

BUILD_TYPE=Debug
HPXC_DIR=${PREFIX}/hpxc
HPX_DIR=${PREFIX}/hpx/cmake-install/${BUILD_TYPE}/lib64/cmake/HPX


mkdir -p ${PREFIX}

if [ ! -d ${HPXC_DIR} ]; then
  git clone -b hpxmp git@github.com:rtohid/hpxc.git ${HPXC_DIR}
fi

cmake                                              		\
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                 		\
  -DHPX_DIR=${HPX_DIR}                             		\
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON               		\
  -DCMAKE_CXX_FLAGS="-std=c++17"                   		\
  -DCMAKE_CXX_COMPILER=g++                         		\
  -DCMAKE_C_COMPILER=gcc                           		\
  -Wdev -S ${HPXC_DIR} -B ${HPXC_DIR}/cmake-build/${BUILD_TYPE} \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  # -DHPXC_WITH_RW_LOCK=ON                            \

cmake --build ${HPXC_DIR}/cmake-build/${BUILD_TYPE}/ --parallel 
cmake --install ${HPXC_DIR}/cmake-build/${BUILD_TYPE}/ --prefix ${HPXC_DIR}/cmake-install/${BUILD_TYPE}

