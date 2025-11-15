{ lib
, buildPythonPackage
, cudaPackages
, ninja
, setuptools
, wheel
, torch-bin
, numpy
, einops
, transformers
, src
, version
}:

buildPythonPackage rec {
  pname = "flash-linear-attention";
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
    einops
    transformers
  ];

  doCheck = false;

  # Set environment variables for CUDA compilation
  preBuild = ''
    export CUDA_HOME="${cudaPackages.cuda_nvcc}"
    export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0;12.0"
    export NIX_CFLAGS_COMPILE="-I${cudaPackages.cuda_nvcc}/include -I${cudaPackages.libcurand}/include $NIX_CFLAGS_COMPILE"
  '';

  meta = with lib; {
    description = "Efficient implementations of state-of-the-art linear attention models in PyTorch and Triton";
    homepage = "https://github.com/fla-org/flash-linear-attention";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
