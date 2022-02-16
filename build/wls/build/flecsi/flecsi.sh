#!/bin/bash -e

ARGS=$@
FILENAME=$0
NUM_JOBS=`grep -c ^processor /proc/cpuinfo`

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
        --cinch-branch)
            CINCH_BRANCH="$2"
            shift
            shift
            ;;
        --cinch-remote)
            CINCH_REMOTE="$2"
            shift
            shift
            ;;
        --cinch-remote-url)
            CINCH_REMOTE_URL="$2"
            shift
            shift
            ;;
        -dc|--distclean)
            COMMAND="distclean"
            BUILD_TYPE="${2^}"
            shift
            shift
            ;;
        --flecsi-remote)
            FLECSI_REMOTE="$2"
            shift
            shift
            ;;
        --flecsi-remote-url)
            FLECSI_REMOTE_URL="$2"
            shift
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
        -j|--jobs)
            NUM_JOBS=$2
            shift
            shift
            ;;
        --log)
            LOG=true
            shift
            ;;
        -p|--pull)
            PULL=true
            shift
            ;;
        --pull-cinch)
            CINCH_PULL=true
            shift
            ;;
        --prefix)
            INSTALL_DIR="$2"
            shift
            shift
            ;;
        -q|--quick)
            QUICK_BUILD=true
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

if [ "$QUICK_BUILD" = true ]; then
    #BRANCH='hpx_backend_rebooted'
    #FLECSI_REMOTE=stellar
    #FLECSI_REMOTE_URL='https://github.com/STEllAR-GROUP/flecsi.git'
    #CINCH_REMOTE='origin'
    #CINCH_BRANCH='fix/boost'
    BUILD_TYPE='Debug'
    COMMAND='install'
fi

if [ -z "$SRC_PATH" ]; then
    SRC_PATH=/home/$USER/src/FleCSI
fi

if [ -z "$INSTALL_DIR" ]; then
    INSTALL_ROOT=/home/$USER/install/FleCSI
    INSTALL_DIR=$INSTALL_ROOT/flecsi/$BUILD_TYPE
fi

if [ -z "$HPX_CMAKE_PATH" ]; then
    HPX_CMAKE_PATH=$INSTALL_ROOT/flecsi-third-party/$BUILD_TYPE/lib/cmake/HPX/
fi

FLECSI_DIR=$SRC_PATH/flecsi
BUILD_DIR=/home/$USER/build/FleCSI/flecsi/$BUILD_TYPE

if [ "$BUILD_TYPE" != "Debug" ] && [ "$BUILD_TYPE" != "Release" ] && [ "$BUILD_TYPE" != "RelWithDebInfo" ]; then
    echo "Invalid build type '$BUILD_TYPE'. Please pick one of the following build types:"
    echo "$FILENAME $COMMAND [Debug, Release, RelWithDebInfo]"
    exit -1
fi

clean_flecsi()
{
    cd $BUILD_DIR
    echo "Running 'make clean' in $BUILD_DIR"
    make clean
}


distclean_flecsi()
{
    echo "Removing $BUILD_DIR"
    rm -rf $BUILD_DIR
    echo "Removing $INSTALL_DIR"
    rm -rf $INSTALL_DIR
}

setup_src()
{
    cd $SRC_PATH
    
    if [ ! -d $FLECSI_DIR ]; then
        git clone --recursive https://github.com/laristra/flecsi.git $FLECSI_DIR
    fi

    cd $FLECSI_DIR
    if [ ! -z $FLECSI_REMOTE_URL ]; then
      set +e
      git ls-remote --exit-code $FLECSI_REMOTE 2>&1 > /dev/null
      if test $? != 0; then
        git remote add $FLECSI_REMOTE $FLECSI_REMOTE_URL
      fi
      set -e
    fi
    if [ ! -z $BRANCH ]; then
        if [ ! -z $FLECSI_REMOTE ]; then
            git fetch $FLECSI_REMOTE
        fi
        git checkout $BRANCH
    fi
    if [ "$PULL" = true ]; then
        git pull
    fi

    cd cinch
    if [ ! -z $CINCH_REMOTE_URL ]; then
        git remote add $CINCH_REMOTE $CINCH_REMOTE_URL
    fi
    if [ ! -z $CINCH_BRANCH ]; then
        if [ ! -z $CINCH_REMOTE ]; then
            git fetch $CINCH_REMOTE
        fi
        git checkout $CINCH_BRANCH
    fi
    if [ "$CINCH_PULL" = true ]; then
        git pull
    fi
}

build_flecsi()
{
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
     cmake \
        -DENABLE_METIS=ON                                                          \
        -DENABLE_PARMETIS=ON                                                       \
        -DENABLE_COLORING=ON                                                       \
        -DENABLE_UNIT_TESTS=ON                                                     \
        -DENABLE_DEVEL_TARGETS=ON                                                  \
        -DHPX_DIR=$HPX_CMAKE_PATH                                                  \
        -DFLECSI_RUNTIME_MODEL=hpx                                                 \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE                                             \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR                                       \
        -DCMAKE_PREFIX_PATH=$INSTALL_ROOT/flecsi-third-party/$BUILD_TYPE \
        -Wdev                                                                      \
        $FLECSI_DIR
    
     make -j $NUM_JOBS
}

install_flecsi()
{
    build_flecsi
    cd $BUILD_DIR
     make -j $NUM_JOBS install
}

test_flecsi()
{
    build_flecsi
    cd $BUILD_DIR
     make -j $NUM_JOBS test
}

# Get on the correct branch on flecsi and cinch.
setup_src

# Run the command.
if [ "$COMMAND" = "clean" ]; then
    clean_flecsi
fi

if [ "$COMMAND" = "distclean" ]; then
    distclean_flecsi
fi

if [ "$COMMAND" = "build" ]; then
    if ["$LOG" = true]; then
        build_flecsi 2>&1 | tee -a $LOG_FILE
    else
        build_flecsi
    fi
fi

if [ "$COMMAND" = "install" ]; then
    if ["$LOG" = true]; then
        install_flecsi 2>&1 | tee -a $LOG_FILE
    else
        install_flecsi
    fi
fi

if [ "$COMMAND" = "test" ]; then
    if ["$LOG" = true]; then
        test_flecsi 2>&1 | tee -a $LOG_FILE
    else
        test_flecsi
    fi
fi

