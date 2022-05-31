module load openmpi cuda/11.5 llvm/14.0.0
                                                                                                 
rm -rf ${WORK}/experiments/kokkos-spack
mkdir ${WORK}/experiments/kokkos-spack
cd ${WORK}/experiments/kokkos-spack
                                                                                                 
git clone https://github.com/spack/spack.git
source ${WORK}/experiments/kokkos-spack/spack/share/spack/setup-env.sh
spack env create -d .
spack env activate -p .
                                                                                                 
spack compiler find
spack external find cmake cuda openmpi

spack add kokkos%clang@14.0.0 +cuda ~openmp +cuda_lambda ~wrapper cuda_arch=70
# spack concretize -f
