#!/bin/bash

usage="$(basename "$0") [-h] -- program to install packages needed for LISA Analysis Tools Workshop

where:
    -h  show this help text

keyword argument options (given as key=value):
    env_name:  Name of generated conda environment. Default is 'lisa_env'.
    # run_tests: Either true or false. Whether to run tests after install. Default is true.
    
"

while getopts 'h' option; do
  case "$option" in
    h) echo "$usage"
       exit 3
       ;;
  esac
done

for ARGUMENT in "$@"
do
   KEY=$(echo $ARGUMENT | cut -f1 -d=)

   KEY_LENGTH=${#KEY}
   VALUE="${ARGUMENT:$KEY_LENGTH+1}"

   export "$KEY"="$VALUE"
done

if [ -z ${env_name+x} ]; then env_name="2050_env"; fi
# if [ -z ${run_tests+x} ]; then run_tests="true"; fi

# if [[ "$run_tests" != "true" ]] && [[ "$run_tests" != "false" ]]; 
#     then echo "run_tests variable must be 'true' or 'false'.";
#     exit 2;
# fi

echo "Now installing into conda environment named $env_name."

echo "Installing space 2050 setup."; 

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "This system is macOS."

    machine=$(uname -m)
    if [[ "$machine" == "arm64" ]]; then
        echo "This is an M1 Mac."
        conda create -n "$env_name" -c conda-forge -y wget gsl hdf5 numpy pandas Cython scipy tqdm  openblas lapack liblapacke jupyter ipython h5py requests matplotlib python=3.12
    else
        echo "This is not an M1 Mac."
        conda create -n "$env_name" -c conda-forge -y clangxx_osx-64 clang_osx-64 wget gsl  openblas lapack liblapacke hdf5 numpy pandas Cython scipy tqdm jupyter ipython h5py requests matplotlib python=3.12
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "This system is Unix/Linux."
    conda create -n "$env_name" -c conda-forge -y gcc_linux-64 gxx_linux-64 wget gsl  openblas lapack liblapacke hdf5 numpy pandas Cython scipy tqdm jupyter ipython h5py requests matplotlib python=3.12
else
    echo "Unsupported operating system."
fi

# get conda base information
IN="$(conda info | grep -i 'base environment')"

tmp=$(echo $IN | tr " " "\n")
i=0
out=()
for tmp_i in $tmp
do
    out[i]=$tmp_i
    let "i = $i + 1"
done

conda_base="${out[3]}"
conda_init_sh="$conda_base/etc/profile.d/conda.sh"
echo "$conda_init_sh"
source $conda_init_sh

conda activate "$env_name"
echo "should be done"
conda_check="$(conda info | grep -i 'active environment')"
echo "conda env: $conda_check"
echo "Environment created. Installing additional packages before FEW install."

python_here=""$conda_base"/envs/"$env_name"/bin/python"
pip_here=""$conda_base"/envs/"$env_name"/bin/pip"

echo "python: $python_here" 
echo "pip: $pip_here"

"$pip_here" install corner eryn chainconsumer mpmath;

machine=$(uname -m)
if [[ "$machine" == "arm64" ]]; then
    extra_args="--ccbin /usr/bin/"
else
    extra_args=
fi

git clone https://github.com/mikekatz04/LISAanalysistools.git
cd LISAanalysistools/
git checkout space2050
"$python_here" -m pip install . $extra_args
cd ../

echo "CHECK"
git clone https://github.com/mikekatz04/GBGPU.git
cd GBGPU/
git checkout add_orbits
"$python_here" scripts/prebuild.py 
"$python_here" -m pip install . $extra_args
cd ../
rm -rf GBGPU

echo "CHECK2"
git clone https://github.com/mikekatz04/BBHx.git
cd BBHx/
git checkout add_orbits
"$python_here" scripts/prebuild.py 
cp ../LISAanalysistools/src/Detector.cpp src/
cp ../LISAanalysistools/src/pycppdetector.pyx src/
cp ../LISAanalysistools/include/Detector.hpp include/
"$python_here" -m pip install . $extra_args
cd ../
rm -rf BBHx

echo "CHECK3"
git clone https://github.com/mikekatz04/lisa-on-gpu.git
cd lisa-on-gpu/
"$python_here" scripts/prebuild.py 
cp ../LISAanalysistools/src/Detector.cpp src/
cp ../LISAanalysistools/src/pycppdetector.pyx src/
cp ../LISAanalysistools/include/Detector.hpp include/
"$python_here" -m pip install . $extra_args
cd ../
rm -rf lisa-on-gpu

"$python_here" -m pip install fastemriwaveforms $extra_args

rm -rf LISAanalysistools/

# if [[ "$machine" == "arm64" ]]; then
#     "$python_here" -m pip install git+https://github.com/mikekatz04/LISAanalysistools.git@space2050 --ccbin /usr/bin/
#     "$python_here" -m pip install fastlisaresponse --ccbin /usr/bin/
#     "$python_here" -m pip install git+https://github.com/mikekatz04/BBHx.git@add_orbits --ccbin /usr/bin/
#     "$python_here" -m pip install fastemriwaveforms --ccbin /usr/bin/
#     "$python_here" -m pip install git+https://github.com/mikekatz04/GBGPU.git@add_orbits --ccbin /usr/bin/
# else
#     "$python_here" -m pip install git+https://github.com/mikekatz04/LISAanalysistools.git@space2050
#     "$python_here" -m pip install fastlisaresponse
#     "$python_here" -m pip install git+https://github.com/mikekatz04/BBHx.git@add_orbits
#     "$python_here" -m pip install fastemriwaveforms
#     "$python_here" -m pip install git+https://github.com/mikekatz04/GBGPU.git@add_orbits
# fi

# conda activate "$env_name"
# if [[ "$run_tests" == "true" ]]; 
#  then echo "Running tests...";
#  "$python_here" -m unittest discover;
# fi
