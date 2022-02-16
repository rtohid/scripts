#!/bin/bash -x

USER=stellar
SRC_PATH=/home/$USER/src
BUILD_DIR=/home/$USER/build/pybind11/$2
INSTALL_DIR=/home/$USER/install/pybind11/$2

PYBIND11_DIR=$SRC_PATH/pybind11

BUILD_TYPE=$2

if [ "$1" = "clean" ]; then
  cd $BUILD_DIR
  make clean
  exit 0
fi

if [ "$1" = "distclean" ]; then
  rm -rf $INSTALL_DIR $BUILD_DIR
  exit 0
fi

cd $SRC_PATH

if [ ! -d $PYBIND11_DIR ]; then
  git clone https://github.com/pybind/pybind11.git $PYBIND11_DIR
fi

if [ ! -d "$BUILD_DIR" ]; then
  mkdir -p "$BUILD_DIR"

  cd "$BUILD_DIR"

  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR                                     \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE                                          \
        -DPYBIND11_SMP_THREADS=C++11                                            \
        $PYBIND11_DIR
fi   

cd "$BUILD_DIR"

make -j 16
make -j 16 install

