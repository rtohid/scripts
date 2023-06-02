#!/bin/bash

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

EXAMPLE_PATH=${PREFIX}/running_examples
BUILD_TYPE=Debug
PROJECT=examples
HPX_DIR=${PREFIX}/hpx/cmake-install/${BUILD_TYPE}/lib/cmake/HPX
LOG_FILE=${PREFIX}/logs/${PROJECT}-build-options.log

sh ${PREFIX}/build-omp.sh

mkdir -p ${PREFIX}
mkdir -p logs

# Logging the configuration
CONFIG="cmake
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
  -DCMAKE_VERBOSE_MAKEFILE=ON
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
  -DCMAKE_CXX_FLAGS=\"-std=c++17 -fopenmp\"
  -DCMAKE_CXX_COMPILER=clang++
  -DCMAKE_C_COMPILER=clang
  -DHPX_DIR=${HPX_DIR}
  -DOMP_LIB_PATH=${PREFIX}/llvm-project/openmp/cmake-install-omp/${BUILD_TYPE}/lib/libomp.so
  -Wdev -S ${EXAMPLE_PATH} -B ${EXAMPLE_PATH}/cmake-build-omp/${BUILD_TYPE}

cmake --build ${EXAMPLE_PATH}/cmake-build-omp/${BUILD_TYPE}/ --parallel
cmake --install ${EXAMPLE_PATH}/cmake-build-omp/${BUILD_TYPE}/ --prefix ${EXAMPLE_PATH}/cmake-install-omp/${BUILD_TYPE}
"

echo "${CONFIG}"

# Writing the config to file.
LOG="$(date); running $0 from $(pwd)" >> ${LOG_FILE}
LINE="~"
for i in $(seq 2 ${#LOG}); do
  LINE+="~"
done
echo ${LOG} >> ${LOG_FILE}
echo ${LINE} >> ${LOG_FILE}
echo "${CONFIG}" >> ${LOG_FILE}
echo >> ${LOG_FILE}


rm -rf ${EXAMPLE_PATH}/cmake-build

cmake                                                                                     \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                                                        \
  -DCMAKE_VERBOSE_MAKEFILE=ON                                                             \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                                                      \
  -DCMAKE_CXX_FLAGS="-std=c++17 -fopenmp"                                                 \
  -DCMAKE_CXX_COMPILER=clang++                                                            \
  -DCMAKE_C_COMPILER=clang                                                                \
  -DHPX_DIR=${HPX_DIR}                                                                    \
  -DOMP_LIB_PATH=${PREFIX}/llvm-project/openmp/cmake-install-omp/${BUILD_TYPE}/lib/libomp.so  \
  -Wdev -S ${EXAMPLE_PATH} -B ${EXAMPLE_PATH}/cmake-build-omp/${BUILD_TYPE}

cmake --build ${EXAMPLE_PATH}/cmake-build-omp/${BUILD_TYPE}/ --parallel
cmake --install ${EXAMPLE_PATH}/cmake-build-omp/${BUILD_TYPE}/ --prefix ${EXAMPLE_PATH}/cmake-install-omp/${BUILD_TYPE}
