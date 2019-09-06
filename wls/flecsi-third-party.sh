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
        --ftp-remote)
            FTP_REMOTE="$2"
            shift
            shift
            ;;
        --ftp-remote-url)
            FTP_REMOTE_URL="$2"
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
    #BRANCH='fix-hpx-build'
    #FTP_REMOTE='rtohid'
    #FTP_REMOTE_URL='https://github.com/rtohid/flecsi-third-party.git'
    CINCH_REMOTE='origin'
    CINCH_BRANCH='fix/boost'
    BUILD_TYPE='Debug'
    COMMAND='install'
fi

if [ -z "$SRC_PATH" ]; then
    SRC_PATH=/mnt/c/Users/$USER/src/FleCSI
    mkdir -p $SRC_PATH
fi

if [ -z "$INSTALL_DIR" ]; then
    INSTALL_ROOT=/mnt/c/Users/$USER/install/FleCSI
    INSTALL_DIR=$INSTALL_ROOT/flecsi-third-party/$BUILD_TYPE
fi

FTP_DIR=$SRC_PATH/flecsi-third-party
BUILD_DIR=/mnt/c/Users/$USER/build/FleCSI/flecsi-third-party/$BUILD_TYPE

if [ "$BUILD_TYPE" != "Debug" ] && [ "$BUILD_TYPE" != "Release" ] && [ "$BUILD_TYPE" != "RelWithDebInfo" ]; then
    echo "Invalid build type '$BUILD_TYPE'. Please pick one of the following build types:"
    echo "$FILENAME $COMMAND [Debug, Release, RelWithDebInfo]"
    exit -1
fi

clean_ftp()
{
    cd $BUILD_DIR
    echo "Running 'make clean' in $BUILD_DIR"
    make clean
}

distclean_ftp()
{
    echo "Removing $BUILD_DIR"
    rm -rf $BUILD_DIR
    echo "Removing $INSTALL_DIR"
    rm -rf $INSTALL_DIR
}

setup_src()
{
    cd $SRC_PATH
    
    if [ ! -d $FTP_DIR ]; then
        git clone --recursive https://github.com/laristra/flecsi-third-party.git $FTP_DIR
    fi

    cd $FTP_DIR
    if [ ! -z $FTP_REMOTE_URL ]; then
        set +e
        git ls-remote --exit-code $FTP_REMOTE 2>&1 > /dev/null
        if test $? != 0; then
            git remote add $FTP_REMOTE $FTP_REMOTE_URL
        fi
        set -e
    fi
    if [ ! -z $BRANCH ]; then
        if [ ! -z $FTP_REMOTE ]; then
            git fetch $FTP_REMOTE
        fi
        git checkout $BRANCH
    fi
    if [ "$PULL" = true ]; then
        git pull
    fi

    cd cinch
    if [ ! -z $CINCH_REMOTE_URL ]; then
        set +e
        git ls-remote --exit-code $CINCH_REMOTE 2>&1 > /dev/null
        if test $? != 0; then
            git remote add $CINCH_REMOTE $CINCH_REMOTE_URL
        fi
        set -e
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

build_ftp()
{
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    cmake \
        -DBUILD_SHARED_LIBS=ON                                                 \
        -DCMAKE_BUILD_TYPE=$BUILD_TYPE                                         \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR                                   \
        -DENABLE_METIS=ON                                                      \
        -DMETIS_MODEL=parallel                                                 \
        -DENABLE_HPX=ON                                                        \
        -DENABLE_EXODUS=ON                                                     \
        -DENABLE_LEGION=OFF                                                    \
        $FTP_DIR
    
    make VERBOSE=1 -j $NUM_JOBS
}

install_ftp()
{
    build_ftp
    cd $BUILD_DIR
    make VERBOSE=1 -j $NUM_JOBS install
}

test_ftp()
{
    build_ftp
    cd $BUILD_DIR
    make -j $NUM_JOBS test
}

# Get on the correct branch on flecsi-third-party and cinch.
setup_src

# Run the command.
if [ "$COMMAND" = "clean" ]; then
    clean_ftp
fi

if [ "$COMMAND" = "distclean" ]; then
    distclean_ftp
fi

if [ "$COMMAND" = "build" ]; then
    if ["$LOG" = true]; then
        build_ftp 2>&1 | tee -a $LOG_FILE
    else
        build_ftp
    fi
fi

if [ "$COMMAND" = "install" ]; then
    if ["$LOG" = true]; then
        install_ftp 2>&1 | tee -a $LOG_FILE
    else
        install_ftp
    fi
fi

if [ "$COMMAND" = "test" ]; then
    if ["$LOG" = true]; then
        test_ftp 2>&1 | tee -a $LOG_FILE
    else
        test_ftp
    fi
fi

