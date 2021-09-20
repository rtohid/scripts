#!/bin/bash

BASE_DIR=/work/`whoami`/vasculature
mkdir -p ${BASE_DIR}
VCPKG_DIR=${BASE_DIR}/vcpkg

cd ${BASE_DIR}
git clone https://github.com/microsoft/vcpkg.git
${VCPKG_DIR}/bootstrap-vcpkg.sh -disableMetrics

${VCPKG_DIR}/vcpkg install parmetis

${VCPKG_DIR}/vcpkg install hypre
# The package hypre:x64-linux provides CMake targets:

#     find_package(HYPRE CONFIG REQUIRED)
#     target_link_libraries(main PRIVATE HYPRE::HYPRE)

${VCPKG_DIR}/vcpkg install hdf5
# The package hdf5:x64-linux provides CMake targets:

#     find_package(hdf5 CONFIG REQUIRED)
#     target_link_libraries(main PRIVATE hdf5::hdf5-static hdf5::hdf5_hl-static)

# CLHEP
CLHEP_DIR=${BASE_DIR}/clhep
cd ${BASE_DIR}
git clone https://gitlab.cern.ch/CLHEP/CLHEP.git clhep
cd ${CLHEP_DIR}
cmake -G Ninja  -S . -B cmake-build-release
cmake --build cmake-build-release --parallel
cmake --install cmake-build-release --prefix ${CLHEP_DIR}/cmake-install-release

# Google Test
GoogleTest=${BASE_DIR}/googletest
cd ${BASE_DIR}
git clone https://github.com/google/googletest.git
cd ${GoogleTest}
cmake -G Ninja  -S . -B cmake-build-release
cmake --build cmake-build-release --parallel
cmake --install cmake-build-release --prefix ${GoogleTest}/cmake-install-release

