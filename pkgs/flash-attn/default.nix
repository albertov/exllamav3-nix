{ lib
, buildPythonPackage
, cudaPackages
, ninja
, setuptools
, wheel
, torch-bin
, numpy
, psutil
, src
, version
}:

buildPythonPackage rec {
  pname = "flash-attn";
  inherit version;
  format = "setuptools";

  inherit src;

  nativeBuildInputs = [
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
    ninja
    setuptools
    wheel
  ];

  buildInputs = [
    cudaPackages.cuda_cudart
    cudaPackages.libcublas
    cudaPackages.libcusparse
    cudaPackages.libcusolver
    cudaPackages.libcurand
  ];

  propagatedBuildInputs = [
    torch-bin
    numpy
    psutil
  ];

  doCheck = false;

  # Set environment variables for CUDA compilation
  preBuild = ''
    export CUDA_HOME="${cudaPackages.cuda_nvcc}"
    export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0;12.0"
    export NIX_CFLAGS_COMPILE="-I${cudaPackages.cuda_nvcc}/include -I${cudaPackages.libcurand}/include $NIX_CFLAGS_COMPILE"
  '';

  meta = with lib; {
    description = "Fast and memory-efficient exact attention with IO-awareness";
    homepage = "https://github.com/Dao-AILab/flash-attention";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
