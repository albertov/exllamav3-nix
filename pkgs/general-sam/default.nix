{ lib
, buildPythonPackage
, fetchPypi
, rustPlatform
, stdenv
, darwin
}:

buildPythonPackage rec {
  pname = "general-sam";
  version = "1.0.0";
  format = "pyproject";

  src = fetchPypi {
    pname = "general_sam";
    inherit version;
    hash = "sha256-iSeonFBV9M7HN+TxTXp6N17dGY3sjrfor5/2hr6nH4c=";
  };

  postUnpack = ''
    cp ${./Cargo.lock} general_sam-${version}/Cargo.lock
  '';

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  doCheck = false;
}
