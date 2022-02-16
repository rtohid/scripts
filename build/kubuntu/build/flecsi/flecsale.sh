#!/bin/bash -e

ARGS=$@
FILENAME=$0
NUM_JOBS=`grep -c ^processor /proc/cpuinfo`

help()
{
    echo "-b|--build"
    echo "-br|--branch"
    echo "-c|--clean"
    echo "--cinch-branch"
    echo "--cinch-remote"
    echo "--cinch-remote-url"
    echo "-dc|--distclean"
    echo "--flecsale-branch"
    echo "--flecsale-remote"
    echo "--flecsale-remote-url"
    echo "--flecsi-branch"
    echo "--flecsi-remote"
    echo "--flecsi-remote-url"
    echo "--help"
    echo "--hpx-cmake-path"
    echo "-i|--install"
    echo "-j|--jobs"
    echo "--log"
    echo "-p|--pull"
    echo "--pull-cinch"
    echo "--prefix"
    echo "-q|--quick"
    echo "--src-path"
    echo "-rt|--runtime"
    echo "--test"
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
      if [ -z "$BUILD_TYPE" ]; then
        echo "Please select the build type:"
        echo "$FILENAME --$COMMAND [Debug, Release, RelWithDebInfo]"
      fi
      shift
      shift
      ;;
    --flecsale-branch)
      FLECSALE_BRANCH="$2"
      shift
      shift
      ;;
    --flecsale-remote)
      FLECSALE_REMOTE="$2"
      shift
      shift
      ;;
    --flecsale-remote-url)
      FLECSALE_REMOTE_URL="$2"
      shift
      shift
      ;;
    --flecsi-branch)
      FLECSI_BRANCH="$2"
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
    --hpx-cmake-path)
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
    --src-path)
      SRC_PATH="$2"
      shift
      shift
      ;;
    -rt|--runtime)
      RUNTIME="${2,,}"
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
  INSTALL_DIR=$INSTALL_ROOT/flecsale/$BUILD_TYPE
fi

if [ -z "$HPX_CMAKE_PATH" ]; then
  HPX_CMAKE_PATH=$INSTALL_ROOT/flecsi-third-party/$BUILD_TYPE/lib/cmake/HPX/
fi

FLECSALE_DIR=$SRC_PATH/flecsale
FLECSALE_CINCH_PATH=$SRC_PATH/flecsale/cinch
FLECSI_DIR=$FLECSALE_DIR/flecsi
FLECSI_CINCH_DIR=$FLECSALE_DIR/flecsi/cinch
BUILD_DIR=/home/$USER/build/flecsale/$BUILD_TYPE/$RUNTIME
INSTALL_DIR=$INSTALL_ROOT/flecsale/$BUILD_TYPE/$RUNTIME

if [ -z "$COMMAND" ]; then
  echo "Please provide a command. See:"
  echo "$FILENAME --help"
  exit -1
fi

if [ "$BUILD_TYPE" != "Debug" ] && [ "$BUILD_TYPE" != "Release" ] && [ "$BUILD_TYPE" != "RelWithDebInfo" ]; then
  echo "Invalid build type '$BUILD_TYPE'. Please pick one of the following build types:"
  echo "$FILENAME $COMMAND [Debug, Release, RelWithDebInfo]"
  exit -1
fi

clean_flecsale()
{
  if [ -z $RUNTIME ];then
    echo "Please select the runtime:"
    echo "$FILENAME --$COMMAND $BUILD_TYPE -rt [mpi, hpx]"
    exit 0
  fi
  cd $BUILD_DIR
  echo "Running 'make clean' in $BUILD_DIR"
  make clean
}


distclean_flecsale()
{
  if [ -z $RUNTIME ];then
    echo "Please select the runtime:"
    echo "$FILENAME --$COMMAND $BUILD_TYPE -rt [mpi, hpx]"
    exit 0
  fi
  echo "Removing $BUILD_DIR"
  rm -rf $BUILD_DIR
  echo "Removing $INSTALL_DIR"
  rm -rf $INSTALL_DIR
}

if [ "$COMMAND" = "clean" ]; then
  clean_flecsale
  exit 0
fi

if [ "$COMMAND" = "distclean" ]; then
  distclean_flecsale
  exit 0
fi

setup_src()
{
  cd $SRC_PATH

  if [ ! -d $FLECSALE_DIR ]; then
    git clone --recursive git@github.com:laristra/flecsale.git $FLECSALE_DIR
  fi

  cd $FLECSALE_DIR
  if [ ! -z $FLECSALE_REMOTE_URL ]; then
    set +e
    git ls-remote --exit-code $FLECSALE_REMOTE 2>&1 > /dev/null
    if test $? != 0; then
      git remote add $FLECSALE_REMOTE $FLECSALE_REMOTE_URL
    fi
    set -e
  fi

  if [ ! -z $BRANCH ]; then
    if [ ! -z $FLECSALE_REMOTE ]; then
      git fetch $FLECSALE_REMOTE
    fi
    git checkout $BRANCH
  fi
  if [ "$PULL" = true ]; then
    git pull
  fi

  cd $FLECSALE_CINCH_PATH
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

  cd $FLECSI_DIR
  if [ ! -z $FLECSI_REMOTE_URL ]; then
    set +e
    git ls-remote --exit-code $FLECSI_REMOTE 2>&1 > /dev/null
    if test $? != 0; then
      git remote add $FLECSI_REMOTE $FLECSI_REMOTE_URL
    fi
    set -e
  fi
  if [ ! -z $FLECSI_BRANCH ]; then
    if [ ! -z $FLECSI_REMOTE ]; then
      git fetch $FLECSI_REMOTE
    fi
    git checkout $FLECSI_BRANCH
  fi
  if [ "$PULL" = true ]; then
    git pull
  fi

  cd $FLECSI_CINCH_DIR
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

build_flecsale()
{
  mkdir -p "$BUILD_DIR"
  cd "$BUILD_DIR"
   cmake \
    -DENABLE_METIS=ON                                                                    \
    -DENABLE_PARMETIS=ON                                                                 \
    -DENABLE_COLORING=ON                                                                 \
    -DENABLE_UNIT_TESTS=ON                                                               \
    -DENABLE_DEVEL_TARGETS=ON                                                            \
    -DFLECSI_RUNTIME_MODEL=$RUNTIME                                               \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE                                                       \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR                                                  \
    -DCMAKE_PREFIX_PATH=/home/$USER/install/FleCSI/flecsi-third-party/$BUILD_TYPE        \
    -Wdev                                                                                \
    $FLECSALE_DIR
    #-DHPX_DIR=$HPX_CMAKE_PATH                                                  \
  #-DBoost_DEBUG=ON                                                           \
    #-DENABLE_DEVEL_TARGETS=ON                                                  \

     make -j $NUM_JOBS
}

install_flecsale()
{
  build_flecsale
  cd $BUILD_DIR
   make -j $NUM_JOBS install
}

test_flecsale()
{
  build_flecsale
  cd $BUILD_DIR
   make -j $NUM_JOBS test
}

# Get on the correct branch on flecsale, flecsi and cinch.
setup_src

# If the log option is set, log the build environment and the corresponding repos.
if [ "$LOG" = true ]; then
  LOG_DIR="/home/$USER/build/logs/flecsale"
  LOG_FILE=$LOG_DIR/"`date +%F-%H-%M`.txt"

  echo 2>&1 | tee -a $LOG_FILE
  echo "Environment" 2>&1 | tee -a $LOG_FILE
  echo "-------------------------------------------------------------------------" 2>&1 | tee -a $LOG_FILE
  printenv 2>&1 | tee -a $LOG_FILE
  echo "=========================================================================" 2>&1 | tee -a $LOG_FILE

  echo 2>&1 | tee -a $LOG_FILE
  echo "FleCSI Third Party Git Log" 2>&1 | tee -a $LOG_FILE
  echo "-------------------------------------------------------------------------" 2>&1 | tee -a $LOG_FILE
  git --git-dir $FLECSALE_DIR/.git log -1 2>&1 | tee -a $LOG_FILE

  echo 2>&1 | tee -a $LOG_FILE
  echo "FleCSI Third Party Branch"
  echo "-------------------------------------------------------------------------" 2>&1 | tee -a $LOG_FILE
  git --git-dir $FLECSALE_DIR/.git branch -vv 2>&1 | tee -a $LOG_FILE
  echo "=========================================================================" 2>&1 | tee -a $LOG_FILE

  echo 2>&1 | tee -a $LOG_FILE
  echo "Cinch Git Log" 2>&1 | tee -a $LOG_FILE
  echo "-------------------------------------------------------------------------" 2>&1 | tee -a $LOG_FILE
  git --git-dir $FLECSALE_DIR/cinch/.git log -1 2>&1 | tee -a $LOG_FILE

  echo 2>&1 | tee -a $LOG_FILE
  echo "Cinch Branch"
  echo "-------------------------------------------------------------------------" 2>&1 | tee -a $LOG_FILE
  git --git-dir $FLECSALE_DIR/cinch/.git branch -vv 2>&1 | tee -a $LOG_FILE
  echo "=========================================================================" 2>&1 | tee -a $LOG_FILE
fi

# Run the command.
if [ "$COMMAND" = "build" ]; then
  if [ "$LOG" = true ]; then
    echo "Build Log" 2>&1 | tee -a $LOG_FILE
    echo "-------------------------------------------------------------------------" 2>&1 | tee -a $LOG_FILE
    build_flecsale 2>&1 | tee -a $LOG_FILE
    echo "=========================================================================" 2>&1 | tee -a $LOG_FILE
  else
    build_flecsale
  fi
fi

if [ "$COMMAND" = "install" ]; then
  if [ "$LOG" = true ]; then
    echo "Install Log" 2>&1 | tee -a $LOG_FILE
    echo "-------------------------------------------------------------------------" 2>&1 | tee -a $LOG_FILE
    install_flecsale 2>&1 | tee -a $LOG_FILE
    echo "=========================================================================" 2>&1 | tee -a $LOG_FILE
  else
    install_flecsale
  fi
fi

if [ "$COMMAND" = "test" ]; then
  if [ "$LOG" = true ]; then
    echo "Test Log" 2>&1 | tee -a $LOG_FILE
    echo "-------------------------------------------------------------------------" 2>&1 | tee -a $LOG_FILE
    test_flecsale 2>&1 | tee -a $LOG_FILE
    echo "=========================================================================" 2>&1 | tee -a $LOG_FILE
  else
    test_flecsale
  fi
fi

