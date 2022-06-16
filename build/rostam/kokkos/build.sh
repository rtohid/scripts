#!/bin/bash

# Copyright (c) 2022 R. Tohid (@rtohid)
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

module load llvm/14.0.0
module load cuda/11.5

BUILD_TYPE=Release

BASE_DIR=/work/${USER}/experiments/Kokkos

KOKKOS_DIR=${BASE_DIR}/kokkos
TUTORIALS_DIR=${BASE_DIR}/kokkos-tutorials


ARCH=$(
  case "$(hostname -s)" in
    (toranj*) echo AMPERE80 ;;
    (diablo) echo VOLTA70 ;;
  esac)

# Clone repos
mkdir -p ${BASE_DIR}

cd ${BASE_DIR}
rm -rf kokkos kokkos-tutorials
git clone https://github.com/kokkos/kokkos ${KOKKOS_DIR}
# git clone https://github.com/kokkos/kokkos-tutorials ${TUTORIALS_DIR}

# Build Kokkos
cmake -G Ninja                       \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE     \
  -DKokkos_ENABLE_CUDA=ON            \
  -DKokkos_ENABLE_CUDA_LAMBDA=ON     \
  -DKokkos_ARCH_VOLTA70=ON           \
  -DCMAKE_C_COMPILER=clang           \
  -DCMAKE_CXX_COMPILER=clang++       \
  -DCMAKE_CUDA_COMPILER=clang++      \
  -DKokkos_CXX_STANDARD=17           \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -S ${KOKKOS_DIR}                   \
  -B ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE

cmake --build ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE --parallel
cmake --install ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE --prefix ${KOKKOS_DIR}/cmake-install/$BUILD_TYPE

