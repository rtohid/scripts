#!/bin/bash -e

FILENAME=$0
ARGS=$@

COMMAND=""
BUILD_TYPE=""
PHYLANX_REMOTE=""
PHYLANX_REMOTE_URL=""

help()
{
    echo \
        "
    -b, --build
    Build phylanx with the specified build type, e.g., --build debug
    -br, --branch
    Set the git branch, e.g., --branch master
    -c, --clean
    Run make clean in the build directory of specified build type.
    e.g., --clean debug
    -dc, --distclean
    Remove build and install directories of specidied build typy.
    e.g., --distclean debug
    -env, --print-environment
    Print name and value of all environment variables before building phylanx.
    --help
    print this help.
    --hpx-path
    Set HPX_CMAKE_PATH.
    -i, --install
    Install phylanx with the specified build type, e.g., --install debug
    --malloc
    Set the malloc used by HPX. default is 'system'
    -p, --pull
    Run git pull before building Phylanx.
    --phylanx-remote
    Set the Phylanx remote to work with.
    --phylanx-remote-url
    Set the URL of a new remote.
    --prefix
    Installation path.
    --src-path
    Phylanx source path.
    --test
    Build tests.
    "
}

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
        -br|--branch)
            BRANCH="$2"
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
        -env|--print-environment)
            PRINT_ENIRONMENT=true
            shift
            ;;
        --help)
            help
            exit 0
            shift
            ;;
        --hpx-path)
            HPX_CMAKE_PATH="$2"
            shift
            shift
            ;;
        -i|--install)
            COMMAND="install"
            BUILD_TYPE="${2^}"
            shift
            shift
            ;;
        --malloc)
            MALLOC="$2"
            shift
            shift
            ;;
        -p|--pull)
            PULL=true
            shift
            ;;
        --phylanx-remote)
            PHYLANX_REMOTE="$2"
            shift
            shift
            ;;
        --phylanx-remote-url)
            PHYLANX_REMOTE_URL="$2"
            shift
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
        --test)
            TEST=true
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

if [ -z "$INSTALL_DIR" ]; then
    INSTALL_ROOT=/home/$USER/install
    INSTALL_DIR=$INSTALL_ROOT/phylanx_tensor/$BUILD_TYPE
fi

if [ -z "$HPX_CMAKE_PATH" ]; then
    HPX_CMAKE_PATH=$INSTALL_ROOT/hpx/$BUILD_TYPE/lib/cmake/HPX/
fi

if [ -z "$MALLOC" ]; then
    MALLOC="system"
fi

PHYLANX_DIR=$SRC_PATH/phylanx_tensor
BUILD_DIR=/home/$USER/build/phylanx_tensor/$BUILD_TYPE

if [ "$COMMAND" = "" ]; then
    echo "Please provide options, see $0 --help for more info."
    exit -1
fi

if [ "$COMMAND" = "clean" ]; then
    if [ "$BUILD_TYPE" != "Debug" ] && [ "$BUILD_TYPE" != "Release" ] && [ "$BUILD_TYPE" != "RelWithDebInfo" ]; then
        echo "Invalid build type '$BUILD_TYPE'. Please pick one of the following build types:"
        echo "$0 distclean [Debug, Release, RelWithDebInfo]"
        exit -1
    fi
    cd $BUILD_DIR
    echo "Cleaning Phylanx from $BUILD_DIR"
    make clean
    exit 0
fi

if [ "$COMMAND" = "distclean" ]; then
    if [ "$BUILD_TYPE" != "Debug" ] && [ "$BUILD_TYPE" != "Release" ] && [ "$BUILD_TYPE" != "RelWithDebInfo" ]; then
        echo "Invalid build type. Please pick one of the following build types:"
        echo "$0 distclean [Debug, Release, RelWithDebInfo]"
        exit -1
    fi
    echo "Removing $BUILD_DIR"
    rm -rf $BUILD_DIR
    echo "Removing $INSTALL_DIR"
    rm -rf $INSTALL_DIR
    exit 0
fi

build()
{
    if [ "$BUILD_TYPE" != "Debug" ] && [ "$BUILD_TYPE" != "Release" ] && [ "$BUILD_TYPE" != "RelWithDebInfo" ]; then
        echo "Invalid build type '$BUILD_TYPE'. Please pick one of the following build types:"
        echo "$0 --build [Debug, Release, RelWithDebInfo]"
        exit -1
    fi

    if [ ! -d $PHYLANX_DIR ]; then
        git clone https://github.com/STEllAR-GROUP/phylanx.git $PHYLANX_DIR
    fi

    echo "Phylanx's build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    if [ ! -z "$PHYLANX_REMOTE" ]; then
        if [ ! -z "$PHYLANX_REMOTE_URL" ]; then
            echo "Add remote $PHYLANX_REMOTE with url: $PHYLANX_REMOTE_URL"
            git remote add $PHYLANX_REMOTE $PHYLANX_REMOTE_URL
        fi 

        git fetch $PHYLANX_REMOTE

    fi 

    cd "$BUILD_DIR"
    if [ ! -z "$BRANCH" ]; then
        git fetch $PHYLANX_REMOTE
        git checkout $BRANCH
    fi

    if [ "$PULL" = true ]; then
        git pull
    fi

    set -x
    cmake \
        -Dblaze_DIR=$INSTALL_ROOT/blaze/$BUILD_TYPE/share/blaze/cmake/          \
        -DBlazeTensor_DIR=$INSTALL_ROOT/blaze_tensor/$BUILD_TYPE/share/blaze/cmake/          \
        -DPHYLANX_WITH_BLAZE_TENSOR=ON                                          \
        -Dpybind11_DIR=$INSTALL_ROOT/pybind11/$BUILD_TYPE/share/cmake/pybind11/ \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE                                          \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR                                     \
        -DHPX_WITH_MALLOC=$MALLOC                                               \
        -DHPX_DIR=$HPX_CMAKE_PATH                                               \
        -DPHYLANX_WITH_VIM_YCM=ON                                               \
        -Wdev                                                                   \
        $PHYLANX_DIR
    set +x

    make -j 10 # VERBOSE=1

    if [ "$TEST" = true ]; then
        make -j 12 tests
    fi
}

install()
{
    build
    echo "Installing Phylanx in: $INSTALL_DIR"
    make -j 12 install
}

if [ "$COMMAND" = "build" ]; then
    build
fi
if [ "$COMMAND" = "install" ]; then
    install
fi
