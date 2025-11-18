{ stdenv
, lib
, buildPythonPackage
, cudaPackages
, setuptools
, wheel
, packaging
, makeWrapper
, python
, exllamav2
, exllamav3
, fastapi
, uvicorn
, pydantic
, ruamel-yaml
, aiofiles
, aiohttp
, pillow
, psutil
, huggingface-hub
, loguru
, tokenizers
, rich
, jinja2
, sse-starlette
, pydantic-settings
, httpx
, formatron
, kbnf
, async-lru
, httptools
, uvloop
, src
, version
, flash-attn
, flash-linear-attention
, triton-bin
, torch-bin
}:
let
  binPath =  lib.makeBinPath [
    # These are needed to load qwen3-next-80b
    setuptools
    wheel
    packaging
    python.buildEnv
    torch-bin
    triton-bin
    stdenv
    cudaPackages.cuda_nvml_dev
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
    cudaPackages.libcublas
    cudaPackages.libcusparse
    cudaPackages.libcusolver
    cudaPackages.libcurand
  ];
in buildPythonPackage rec {
  pname = "tabbyapi";
  inherit version;
  format = "pyproject";

  inherit src;

  # Patch pyproject.toml to include source files in the package
  # Use find: to automatically discover all packages
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'py-modules = []' 'py-modules = ["main"]
[tool.setuptools.packages.find]
where = ["."]
include = ["backends*", "common*", "endpoints*"]'
  '';

  nativeBuildInputs = [
    setuptools
    wheel
    packaging
    makeWrapper
  ];

  propagatedBuildInputs = [
    # Core dependencies from pyproject.toml
    torch-bin
    triton-bin
    fastapi
    #marisa_trie FIXME
    uvicorn
    pydantic
    ruamel-yaml
    aiofiles
    aiohttp
    pillow
    psutil
    huggingface-hub
    loguru
    tokenizers
    rich
    jinja2
    sse-starlette
    pydantic-settings
    httpx
    formatron
    kbnf
    async-lru
    httptools
    uvloop
    packaging
    # Backend dependencies
    exllamav2
    exllamav3
    flash-attn
    flash-linear-attention
  ];

  # Disable runtime dependency checks as some package names differ
  # (e.g., fastapi vs fastapi-slim) and pydantic version is slightly newer
  pythonRemoveDeps = [
    "fastapi-slim"
    "pydantic"
  ];



  postInstall = ''
    # Create executable wrapper script
    makeWrapper ${python}/bin/python $out/bin/tabbyapi \
      --prefix PYTHONPATH : "$out/${python.sitePackages}:$PYTHONPATH" \
      --prefix PATH : "${binPath}" \
      --set CUDA_HOME "${cudaPackages.cuda_nvcc}" \
      --set TORCH_CUDA_ARCH_LIST "8.0;8.6;8.9;9.0;12.0" \
      --add-flags "-m" \
      --add-flags "main"
  '';

  # Disable tests as they may require GPU or network access
  doCheck = false;

  # Check that the main module and top-level packages can be imported
  # Subpackages are automatically discovered by setuptools find:
  pythonImportsCheck = [
    "main"
    "backends"
    "common"
    "endpoints"
  ];

  meta = with lib; {
    description = "An OAI compatible exllamav2 API that's both lightweight and fast";
    homepage = "https://github.com/theroyallab/tabbyAPI";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    mainProgram = "tabbyapi";
  };
}
