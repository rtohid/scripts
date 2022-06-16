#!/bin/bash

# Copyright (c) 2022 R. Tohid (@rtohid)
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

# set -xe
module load cuda/11.5 hwloc mpich

BUILD_TYPE=Release
BASE_DIR=/work/${USER}/vascular/$(hostname -s)
SPACK_DIR=${BASE_DIR}/spack
KOKKOS_DIR=${BASE_DIR}/kokkos
VASC_DIR=${BASE_DIR}/VascularModeling

ARCH=$(
  case "$(hostname -s)" in
    (toranj*) echo AMPERE80 ;;
    (diablo) echo VOLTA70 ;;
  esac)

mkdir -p ${BASE_DIR}

# Grab code.
if [ ! -d ${VASC_DIR} ]; then
  git clone git@github.com:STEllAR-GROUP/VascularModeling.git ${VASC_DIR}
fi
if [ ! -d ${KOKKOS_DIR} ]; then
  git clone https://github.com/kokkos/kokkos ${KOKKOS_DIR}
fi
if [ ! -d ${SPACK_DIR} ]; then
  git clone https://github.com/spack/spack.git ${SPACK_DIR}
fi


# Set up the environment
if [ "${SPACK_ENV}" ]; then
  despacktivate
fi
if [ -z "${SPACK_ROOT}" ]; then
  source ${SPACK_DIR}/share/spack/setup-env.sh
fi

if [ ! -d ${SPACK_DIR}/.spack-env ]; then
  spack env create -d ${BASE_DIR}
  spack env activate -p ${BASE_DIR}
  sed -i 's/unify: false/unify: true/' ${BASE_DIR}/spack.yaml
  spack compiler find
  spack external find cmake ninja hwloc python mpich
  spack add hdf5^mpich parmetis^mpich metis googletest sleef
  spack concretize
  spack install
fi

spack env activate -p ${BASE_DIR}

METIS_DIR=$(spack find -p metis | egrep "/work.*" -o  | sed -n '2 p')
HYPRE_DIR=$(spack find -p hypre | egrep "/work.*" -o  | sed -n '2 p')
sleef_DIR=$(spack find -p sleef | egrep "/work.*" -o  | sed -n '2 p')
CPATH=$CPATH:$METIS_DIR/include

# Build Kokkos
if [ ! -d ${KOKKOS_DIR}/cmake-install ]; then
  cd ${KOKKOS_DIR}
  cmake -G Ninja                       \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE     \
    -DKokkos_ENABLE_OPENMP=ON          \
    -DKokkos_ENABLE_CUDA=ON            \
    -DKokkos_ENABLE_CUDA_LAMBDA=ON     \
    -DKokkos_ARCH_${ARCH}=ON           \
    -DCMAKE_C_COMPILER=clang           \
    -DCMAKE_CXX_COMPILER=clang++       \
    -DCMAKE_CUDA_COMPILER=clang++      \
    -DKokkos_CXX_STANDARD=17           \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -S ${KOKKOS_DIR}                   \
    -B ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE

  cmake --build ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE --parallel
  cmake --install ${KOKKOS_DIR}/cmake-build/$BUILD_TYPE --prefix ${KOKKOS_DIR}/cmake-install/$BUILD_TYPE
fi

# spack load mpich hdf5 parmetis metis googletest clhep intel-mkl hypre

Build VascularModeling
cd ${VASC_DIR}
cmake -G Ninja                               \
  -DHYPRE_LIBRARY=$HYPRE_DIR/lib/libHYPRE.so \
  -Dsleef_DIRECTORY=$sleef_DIR               \
  -DCMAKE_CXX_FLAGS=-march=native            \
  -DCMAKE_BUILD_TYPE=$BUILD_TYPE             \
  -DCMAKE_C_COMPILER=clang                   \
  -DCMAKE_CXX_COMPILER=clang++               \
  -S ${VASC_DIR} -B ${VASC_DIR}/cmake-build/$BUILD_TYPE

cmake --build ${VASC_DIR}/cmake-build/$BUILD_TYPE --parallel
# cmake --install ${VASC_DIR}/cmake-build/$BUILD_TYPE --prefix ${VASC_DIR}/cmake-install/$BUILD_TYPE

