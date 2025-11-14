{ lib
, buildPythonPackage
, setuptools
, wheel
, packaging
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
    # Use the exllamav3 package from this repo
    exllamav3
  ];

  # Disable tests as they may require GPU or network access
  doCheck = false;

  pythonImportsCheck = [ "tabbyAPI" ];

  meta = with lib; {
    description = "An OAI compatible exllamav2 API that's both lightweight and fast";
    homepage = "https://github.com/theroyallab/tabbyAPI";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
  };
}
