CURRENT_DIR=$1
PREFIX="${CURRENT_DIR:=$(pwd)}"
BUILD_TYPE=Release
LLVM_VERSION=15.0.6


PROJECTS="mlir;clang;openmp"
LLVM_REPO=${PREFIX}/llvm-project/llvm
BUILD_DIR=${PREFIX}/cmake-build/${BUILD_TYPE}
INSTALL_DIR=${PREFIX}/cmake-install/${BUILD_TYPE}

mkdir -p ${PREFIX}
cd ${PREFIX}

if [ ! -d ${LLVM_REPO} ]; then
  git clone git@github.com:llvm/llvm-project.git
  pushd ${LLVM_REPO}
  git checkout -b llvmorg-${LLVM_VERSION} llvmorg-${LLVM_VERSION}
  popd
fi

set +e

touch start-building

cmake -S ${LLVM_REPO} -B ${BUILD_DIR} \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE}    \
  -DLLVM_TARGETS_TO_BUILD="X86"       \
  -DLLVM_ENABLE_PROJECTS=${PROJECTS}  \
  -DLLVM_ENABLE_RTTI=ON               \
  -DLLVM_INSTALL_UTILS=ON             \
  -DLLVM_INCLUDE_TOOLS=ON             \
  -DLLVM_BUILD_EXAMPLES=ON            \
  -DLLVM_ENABLE_ASSERTIONS=ON         \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# cmake --build ${BUILD_DIR} --parallel 32
# cmake --install ${BUILD_DIR}/ --prefix ${INSTALL_DIR}
#
# pushd ${BUILD_DIR}
# make lli
# popd

touch done-building

