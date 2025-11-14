
{ lib
, buildPythonPackage
, cudaPackages
, ninja
, setuptools
, wheel
, pandas
, fastparquet
, torch-bin
, safetensors
, pygments
, websockets
, regex
, numpy
, tokenizers
, rich
, pillow
, src
, version
}:

buildPythonPackage rec {
  pname = "exllamav2";
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
    pandas
    ninja
    wheel
    setuptools
    fastparquet
    torch-bin
    safetensors
    pygments
    websockets
    regex
    numpy
    tokenizers
    rich
    pillow
  ];

  doCheck = true;

  # Set environment variables for CUDA compilation
  preBuild = ''
    export CUDA_HOME="${cudaPackages.cuda_nvcc}"
    export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0;12.0"
    export NIX_CFLAGS_COMPILE="-I${cudaPackages.cuda_nvcc}/include -I${cudaPackages.libcurand}/include $NIX_CFLAGS_COMPILE"
  '';

  meta = with lib; {
    description = "Inference library for running local LLMs on modern consumer GPUs";
    homepage = "https://github.com/turboderp/exllamav2";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
