module load openmpi cuda
                                                                                                 
rm -rf ${WORK}/experiments/kokkos-spack
mkdir ${WORK}/experiments/kokkos-spack
cd ${WORK}/experiments/kokkos-spack
                                                                                                 
git clone https://github.com/spack/spack.git
source ${WORK}/experiments/kokkos-spack/spack/share/spack/setup-env.sh
spack env create -d .
spack env activate -p .
                                                                                                 
spack compiler find
spack external find cmake cuda openmpi

spack add kokkos +cuda ~openmp +cuda_lambda +wrapper cuda_arch=70
spack concretize -f
