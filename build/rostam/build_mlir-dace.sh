#!/bin/bash

# Copyright (c) 2023 R. Tohid (@rtohid)
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"

BUILD_TYPE=Release

MLIR_DACE_DIR=${PREFIX}/mlir-dace
LLVM_DIR=${MLIR_DACE_DIR}/llvm-project

MLIR_DACE_BUILD_DIR=${MLIR_DACE_DIR}/cmake-build/${BUILD_TYPE}
LLVM_BUILD_DIR=${LLVM_DIR}/cmake-build/${BUILD_TYPE}


mkdir -p ${PREFIX}

if [ ! -d ${MLIR_DACE_DIR} ]; then
  git clone --recurse-submodules https://github.com/spcl/mlir-dace
fi

cd ${LLVM_DIR}
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE}   \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DLLVM_ENABLE_PROJECTS="mlir"      \
      -DLLVM_TARGETS_TO_BUILD="host"     \
      -DLLVM_ENABLE_ASSERTIONS=ON        \
      -DCMAKE_BUILD_TYPE=Release         \
      -DCMAKE_C_COMPILER=clang           \
      -DCMAKE_CXX_COMPILER=clang++       \
      -DLLVM_ENABLE_LLD=ON               \
      -DLLVM_INSTALL_UTILS=ON            \
      -S ${LLVM_DIR}/llvm                \
      -B ${LLVM_BUILD_DIR}

cmake --build ${LLVM_BUILD_DIR} --parallel 

cd ${MLIR_DACE_DIR}
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                   \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                 \
      -DCMAKE_C_COMPILER=clang                           \
      -DCMAKE_CXX_COMPILER=clang++                       \
      -DMLIR_DIR=${LLVM_BUILD_DIR}/lib/cmake/mlir/       \
      -DLLVM_EXTERNAL_LIT=${LLVM_BUILD_DIR}/bin/llvm-lit \
      -S ${MLIR_DACE_DIR}                                \
      -B ${MLIR_DACE_BUILD_DIR}

cmake --build ${MLIR_DACE_BUILD_DIR} --target check-sdfg-opt --parallel
cmake --build ${MLIR_DACE_BUILD_DIR}

