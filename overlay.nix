inputs: final: prev: {
  # Override python packages to disable tests that require network access
  python3Packages = prev.python3Packages.override {
    overrides = pyFinal: pyPrev: {
      websockets = pyPrev.websockets.overridePythonAttrs (old: {
        doCheck = false;
      });

      # Add missing Python packages not in nixpkgs
      async-lru = pyFinal.buildPythonPackage rec {
        pname = "async-lru";
        version = "2.0.5";
        format = "setuptools";

        src = pyFinal.fetchPypi {
          pname = "async_lru";
          inherit version;
          hash = "sha256-SB1SzN0nJ19CxDqSi0pQw7+y1nr054sXDj4Ls5xm5bs=";
        };

        propagatedBuildInputs = [ pyFinal.typing-extensions ];
        doCheck = false;
      };

      kbnf = pyFinal.buildPythonPackage rec {
        pname = "kbnf";
        version = "0.4.2-python";
        format = "pyproject";

        src = final.fetchFromGitHub {
          owner = "Dan-wanna-M";
          repo = "kbnf";
          rev = "v${version}";
          hash = "sha256-reefuqS0eExky9qtxBTqwxnZgK8AWFfkrN+VL/lFLyg=";
        };

        nativeBuildInputs = [
          final.rustPlatform.maturinBuildHook
        ];

        buildInputs = final.lib.optionals final.stdenv.isDarwin [
          final.darwin.apple_sdk.frameworks.Security
        ];

        propagatedBuildInputs = [ pyFinal.numpy ];
        doCheck = false;
      };

      formatron = pyFinal.buildPythonPackage rec {
        pname = "formatron";
        version = "0.5.0";
        format = "pyproject";

        src = pyFinal.fetchPypi {
          inherit pname version;
          hash = "sha256-14aqYIuL+2FMDMz2tK21Xy8TIG0PtRfMoFPOf8m8E+Y=";
        };

        nativeBuildInputs = [ pyFinal.setuptools pyFinal.wheel ];
        propagatedBuildInputs = [
          pyFinal.pydantic
          pyFinal.kbnf
          pyFinal.jsonschema
        ];
        doCheck = false;
      };
      exllamav3 = pyFinal.callPackage ./pkgs/exllamav3 {
        inherit (final) cudaPackages ninja;
        inherit (pyFinal) buildPythonPackage setuptools wheel pandas
          fastparquet torch-bin safetensors pygments websockets regex
          numpy tokenizers rich pillow;
        src = inputs.exllamav3;
        version = inputs.exllamav3.shortRev;
      };
      tabby-api = pyFinal.callPackage ./pkgs/tabby-api {
        inherit (final) makeWrapper;
        inherit (pyFinal) buildPythonPackage setuptools wheel packaging python
          fastapi uvicorn pydantic ruamel-yaml aiofiles aiohttp pillow
          psutil huggingface-hub loguru tokenizers rich jinja2 sse-starlette
          pydantic-settings httpx formatron kbnf async-lru httptools uvloop;
        exllamav3 = pyFinal.exllamav3;
        src = inputs.tabby-api;
        version = inputs.tabby-api.shortRev;
      };
    };
  };
}
