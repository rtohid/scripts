#!/bin/bash

set -e

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

BUILD_TYPE=Debug
HPXC_DIR=${PREFIX}/hpxc
HPX_DIR=${PREFIX}/hpx/cmake-install/${BUILD_TYPE}/lib/cmake/HPX
PROJECT=hpxc
LOG_FILE=${PREFIX}/logs/${PROJECT}-build-options.log


mkdir -p ${PREFIX}

# Logging the configuration
CONFIG="cmake
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
  -DHPX_DIR=${HPX_DIR}
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  -DCMAKE_CXX_FLAGS="-std=c++17"
  -DCMAKE_C_STANDARD=17
  -DCMAKE_CXX_COMPILER=clang++
  -DCMAKE_C_COMPILER=clang
  -Wdev -S ${HPXC_DIR} -B ${HPXC_DIR}/cmake-build/${BUILD_TYPE}

cmake --build ${HPXC_DIR}/cmake-build/${BUILD_TYPE}/ --parallel 
cmake --install ${HPXC_DIR}/cmake-build/${BUILD_TYPE}/ --prefix ${HPXC_DIR}/cmake-install/${BUILD_TYPE}
"

echo "${CONFIG}"


if [ ! -d ${HPXC_DIR} ]; then
  git clone -b hpxmp git@github.com:rtohid/hpxc.git ${HPXC_DIR}
fi

cmake                                               \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                  \
  -DHPX_DIR=${HPX_DIR}                              \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                \
  -DCMAKE_CXX_FLAGS="-std=c++17"                    \
  -DCMAKE_C_STANDARD=17                             \
  -DCMAKE_CXX_COMPILER=clang++                      \
  -DCMAKE_C_COMPILER=clang                          \
  -Wdev -S ${HPXC_DIR} -B ${HPXC_DIR}/cmake-build/${BUILD_TYPE}
  # -DHPXC_WITH_RW_LOCK=ON                            \

cmake --build ${HPXC_DIR}/cmake-build/${BUILD_TYPE}/ --parallel 
cmake --install ${HPXC_DIR}/cmake-build/${BUILD_TYPE}/ --prefix ${HPXC_DIR}/cmake-install/${BUILD_TYPE}

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

