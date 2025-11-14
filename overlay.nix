inputs: final: prev: {
  # Override python packages to disable tests that require network access
  python3Packages = prev.python3Packages.override {
    overrides = pyFinal: pyPrev: {
      websockets = pyPrev.websockets.overridePythonAttrs (old: {
        doCheck = false;
      });
      exllamav3 = pyFinal.callPackage ./pkgs/exllamav3 {
        inherit (final) cudaPackages ninja;
        inherit (pyFinal) buildPythonPackage setuptools wheel pandas
          fastparquet torch-bin safetensors pygments websockets regex
          numpy tokenizers rich pillow;
        src = inputs.exllamav3;
        version = inputs.exllamav3.shortRev;
      };
    };
  };
}
