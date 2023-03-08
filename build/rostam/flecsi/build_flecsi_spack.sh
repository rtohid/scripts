#!/bin/bash

#SBATCH --job-name=flecsi_spack_build
#SBATCH --output=flecsi_spack_build.out
#SBATCH --nodes=1
#SBATCH --time=05:00:00
#SBATCH --partition=medusa

# Copyright (c) 2022 R. Tohid (@rtohid)
#
# Distributed under the Boost Software License, Version 1.0. (See accompanying
# file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)

# set -xe
module load openmpi
module load gcc/9.2.1

BASE_DIR=$(pwd)
SPACK_DIR=${BASE_DIR}/spack
FLECSI_DIR=${BASE_DIR}/flecsi

mkdir -p ${BASE_DIR}

if [ ! -d ${FLECSI_DIR} ]; then
  git clone git@github.com:flecsi/flecsi.git ${FLECSI_DIR}
fi
if [ ! -d ${SPACK_DIR} ]; then
  git clone https://github.com/spack/spack.git ${SPACK_DIR}
  source ${SPACK_DIR}/share/spack/setup-env.sh
  spack env create -d ${BASE_DIR}
  spack env activate -p ${BASE_DIR}
  sed -i 's/unify: false/unify: true/' ${BASE_DIR}/spack.yaml
  spack repo add ${FLECSI_DIR}/spack-repo/
  spack external find ninja openmpi hwloc cmake python openssh openssl autoconf automake perl m4
  spack add googletest
  spack add flecsi%gcc@9.2.1 backend=mpi +hdf5 +flog ^openmpi
  spack concretize -f
  spack install
fi

