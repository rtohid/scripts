#!/bin/bash

module unload mvapich2/2.3.3/intel-19.0.5 intel/19.0.5
module load gcc/9.3.0
module load git/2.25.0/gcc-9.3.0

WORK=/work/${USER}
BASE_DIR=${WORK}/vascular
BUILD_TYPE=Release
VASCULAR_DIR=${BASE_DIR}/VascularModeling
VASCULAR_BRANCH=package-as-lib

mkdir ${BASE_DIR}

# install spack
cd ${BASE_DIR}
git clone https://github.com/spack/spack.git
source ${BASE_DIR}/spack/share/spack/setup-env.sh

# install dependenicies
spack install googletest%gcc@9.3.0
spack install mpich%gcc@9.3.0
spack install hdf5+mpi ^mpich%gcc@9.3.0
spack install metis%gcc@9.3.0
spack install parmetis ^mpich%gcc@9.3.0
spack install clhep%gcc@9.3.0
spack install intel-mkl%gcc@9.3.0
spack install hypre ^mpich%gcc@9.3.0

# install sleef vectorization library
cd ${BASE_DIR}
git clone git@github.com:shibatch/sleef.git
cd sleef/
cmake -DCMAKE_BUILD_TYPE=${BUILD_TYPE}  -S . -B cmake-build/${BUILD_TYPE}
cmake --build cmake-build/${BUILD_TYPE} --parallel
cmake --install cmake-build/${BUILD_TYPE} --prefix cmake-install/${BUILD_TYPE}

# install vascular
export METIS_DIR=${WORK}/vascular/spack/opt/spack/linux-rhel7-cascadelake/gcc-9.3.0/metis-5.1.0-2sk2zaevz7q4dq42xfsr6o5ediktxctm
export HYPRE_DIR=${WORK}/vascular/spack/opt/spack/linux-rhel7-cascadelake/gcc-9.3.0/hypre-2.23.0-a2eu3faiboee6awrsg5fbff6iy6hu6qd
export sleef_DIR=${WORK}/vascular/sleef/cmake-install/Release
export CPATH=$CPATH:$METIS_DIR/include

git clone git@github.com:STEllAR-GROUP/VascularModeling.git ${VASCULAR_DIR}
git fetch

cd ${VASCULAR_DIR}
git checkout ${VASCULAR_BRANCH}
cmake -DHYPRE_LIBRARY=$HYPRE_DIR/lib/libHYPRE.so -DCMAKE_CXX_FLAGS=-march=native -Dsleef_DIRECTORY=$sleef_DIR -S . -B cmake-build/Release
cmake --build cmake-build/${BUILD_TYPE} --parallel
cmake --install cmake-build/${BUILD_TYPE} --prefix cmake-install/${BUILD_TYPE}
