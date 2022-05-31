#!/bin/bash

# Copyright (c) 2022 R. Tohid (@rtohid)
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

module load llvm/14.0.0
module load cuda/11.5

BASE_DIR=/work/${USER}/experiments/Kokkos

HPX_DIR=${BASE_DIR}/hpx
KOKKOS_DIR=${BASE_DIR}/kokkos
TUTORIALS_DIR=${BASE_DIR}/kokkos-tutorials

BUILD_TYPE=Release

# Clone repos
mkdir -p ${BASE_DIR}

git clone https://github.com/kokkos/kokkos ${KOKKOS_DIR}
git clone https://github.com/kokkos/kokkos-tutorials ${TUTORIALS_DIR}
git clone git@github.com:STEllAR-GROUP/hpx.git ${HPX_DIR}

# Build HPX
cmake -G Ninja                       \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE     \
  -DHPX_WITH_MALLOC=tcmalloc         \
  -DHPX_WITH_EXAMPLES=OFF            \
  -DCMAKE_CXX_STANDARD=17            \
  -DCMAKE_C_COMPILER=clang           \
  -DCMAKE_CXX_COMPILER=clang++       \
  -DHPX_WITH_CUDA=ON                 \
  -DCMAKE_CUDA_STANDARD=17           \
  -DCMAKE_CUDA_COMPILER=clang        \
  -DHPX_WITH_FETCH_ASIO=ON           \
  -DHPX_WITH_THREAD_IDLE_RATES=ON    \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -Wdev                              \
  -S ${HPX_DIR}                      \
  -B ${HPX_DIR}/cmake-build/$BUILD_TYPE

cmake --build ${HPX_DIR}/cmake-build/$BUILD_TYPE --parallel
cmake --install ${HPX_DIR}/cmake-build/$BUILD_TYPE --prefix ${HPX_DIR}/cmake-install/$BUILD_TYPE

HPX_ROOT=${HPX_DIR}/cmake-install/${BUILD_TYPE}/lib64/cmake/HPX

# Build Kokkos
cmake -G Ninja                       \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE     \
  -DKokkos_ENABLE_CUDA=ON            \
  -DKokkos_ARCH_VOLTA70=ON           \
  -DCMAKE_C_COMPILER=clang           \
  -DCMAKE_CXX_COMPILER=clang++       \
  -DCMAKE_CUDA_COMPILER=clang++      \
  -DKokkos_CXX_STANDARD=17           \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
  -DKokkos_ENABLE_HPX=ON             \
  -DHPX_DIR=${HPX_ROOT}              \
  -S ${KOKKOS_DIR}                   \
  -B ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE

cmake --build ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE --parallel
cmake --install ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE --prefix ${KOKKOS_DIR}/cmake-install/$BUILD_TYPE

