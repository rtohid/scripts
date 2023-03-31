#!/bin/bash

PREFIX=$(pwd)
BUILD_TYPE=Debug
FORK=STEllAR-GROUP
# FORK=gonidelis
# FORK=pnnl
BRANCH=hpx_integration

SRC_DIR=${PREFIX}/NWGraph
BUILD_DIR=${SRC_DIR}/cmake-build/${FORK}/${BUILD_TYPE}
INSTALL_DIR=${SRC_DIR}/cmake-install/${FORK}/${BUILD_TYPE}

HPX_DIR=/work/${USER}/libs/hpx/cmake-install/Debug/lib/cmake/HPX

if [ ! -d ${SRC_DIR} ]; then
	git clone git@github.com:${FORK}/NWGraph.git ${SRC_DIR}
	git --git-dir=${SRC_DIR}/.git --work-tree=${SRC_DIR} checkout ${BRANCH}
fi

cmake -S ${SRC_DIR} -B ${BUILD_DIR} \
	-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	-DNWGRAPH_BUILD_EXAMPLES=ON \
	-DNWGRAPH_BUILD_APBS=ON \
	-DNWGRAPH_BUILD_TESTS=ON \
	-DNWGRAPH_BUILD_BENCH=ON \
	-DCMAKE_CXX_FLAGS="-std=c++20" \
	-DHPX_DIR=${HPX_DIR} \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=ON

cmake --build ${BUILD_DIR} --parallel
# cmake --install ${BUILD_DIR} --prefix ${INSTALL_DIR}
