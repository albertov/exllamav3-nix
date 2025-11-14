{ lib
, buildPythonPackage
, fetchFromGitHub
, rustPlatform
, numpy
, stdenv
, darwin
}:

buildPythonPackage rec {
  pname = "kbnf";
  version = "0.4.2-python";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Dan-wanna-M";
    repo = "kbnf";
    rev = "v${version}";
    hash = "sha256-reefuqS0eExky9qtxBTqwxnZgK8AWFfkrN+VL/lFLyg=";
  };

  cargoLock = ./Cargo.lock;

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  propagatedBuildInputs = [ numpy ];
  doCheck = false;
}
