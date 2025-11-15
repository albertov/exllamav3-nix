{ lib
, buildPythonPackage
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
}:

buildPythonPackage rec {
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
    fastapi
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
