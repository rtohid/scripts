#!/bin/bash -e

FILENAME=$0
ARGS=$@

COMMAND=""
BUILD_TYPE=""

while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -b|--build)
      COMMAND="build"
      BUILD_TYPE="${2^}"
      shift
      shift
      ;;
    -c|--clean)
      COMMAND="clean"
      BUILD_TYPE="${2^}"
      shift
      shift
      ;;
    -dc|--distclean)
      COMMAND="distclean"
      BUILD_TYPE="${2^}"
      shift
      shift
      ;;
    --help)
      help
      exit 0
      shift
      ;;
    -i|--install)
      COMMAND="install"
      BUILD_TYPE="${2^}"
      shift
      shift
      ;;
    -p|--pull)
      PULL=true
      shift
      ;;
    --prefix)
      INSTALL_DIR="$2"
      shift
      shift
      ;;
    --src-path)
      SRC_PATH="$2"
      shift
      shift
      ;;
    *) echo "Invalid argument: $1"
      exit -1
      ;;
  esac
done

if [ -z "$SRC_PATH" ]; then
  SRC_PATH=/home/$USER/src/
fi
BLAZE_DIR=$SRC_PATH/blaze_tensor
BUILD_DIR=/home/$USER/build/blaze_tensor/$BUILD_TYPE

if [ -z "$INSTALL_DIR" ]; then
  INSTALL_ROOT=/home/$USER/install
  INSTALL_DIR=$INSTALL_ROOT/blaze_tensor/$BUILD_TYPE
fi

if [ "$COMMAND" = "" ]; then
  echo "Please provide options, see $0 --help for more info."
  exit -1
fi

if [ "$COMMAND" = "clean" ]; then
  cd $BUILD_DIR
  make clean
  exit 0
fi

if [ "$COMMAND" = "distclean" ]; then
  rm -rf $INSTALL_DIR $BUILD_DIR
  exit 0
fi

build()
{
  if [ "$BUILD_TYPE" != "Debug" ] && [ "$BUILD_TYPE" != "Release" ] && [ "$BUILD_TYPE" != "RelWithDebInfo" ]; then
    echo "Invalid build type '$BUILD_TYPE'. Please pick one of the following build types:"
    echo "$0 --build [Debug, Release, RelWithDebInfo]"
    exit -1
  fi

  if [ ! -d $BLAZE_DIR ]; then
    git clone https://github.com/STEllAR-GROUP/blaze_tensor.git $BLAZE_DIR
  fi

  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"

  if [ "$PULL" = true ]; then
    git pull
  fi

  cmake -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR                                              \
    -DBLAZE_SMP_THREADS=C++11                                                            \
    -Dblaze_DIR=$INSTALL_ROOT/blaze/$BUILD_TYPE/share/blaze/cmake/                       \
    $BLAZE_DIR
  make -j 16
}

install()
{
  build
  make -j 16 install
}

if [ "$COMMAND" = "build" ]; then
  build
fi
if [ "$COMMAND" = "install" ]; then
  install
fi

