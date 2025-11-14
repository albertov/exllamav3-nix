{ lib
, buildPythonPackage
, setuptools
, wheel
, packaging
, makeWrapper
, python
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
}:

buildPythonPackage rec {
  pname = "tabbyapi";
  inherit version;
  format = "pyproject";

  inherit src;

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
    # Use the exllamav3 package from this repo
    exllamav3
  ];

  # Disable runtime dependency checks as some package names differ
  # (e.g., fastapi vs fastapi-slim) and pydantic version is slightly newer
  pythonRemoveRuntimeDependencyCheck = [
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

  pythonImportsCheck = [ "tabbyAPI" ];

  meta = with lib; {
    description = "An OAI compatible exllamav2 API that's both lightweight and fast";
    homepage = "https://github.com/theroyallab/tabbyAPI";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    mainProgram = "tabbyapi";
  };
}
