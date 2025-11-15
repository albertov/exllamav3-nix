{
  description = "ExLlamaV2 - Inference library for running local LLMs on modern consumer GPUs";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
    exllamav3.url = github:turboderp-org/exllamav3;
    exllamav3.flake = false;
    exllamav2.url = github:turboderp-org/exllamav2;
    exllamav2.flake = false;
    flash-attn = {
      type = "git";
      url = "https://github.com/kingbri1/flash-attention";
      ref = "refs/tags/v2.8.3";
      submodules = true;
      flake = false;
    };
    tabby-api.url = github:theroyallab/tabbyAPI;
    tabby-api.flake = false;
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
      let
        overlay = import ./overlay.nix inputs;
      in
  {
      overlays.default = overlay;

      nixosModules = {
        tabbyapi = import ./modules/tabbyapi.nix;
        default = self.nixosModules.tabbyapi;
      };
  } // flake-utils.lib.eachDefaultSystem (system:
      let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ overlay ];
              config = {
                allowUnfree = true;
                cudaSupport = true;
              };
            };
      in
      {
        legacyPackages = pkgs;
        packages = rec {
          inherit (pkgs.python3Packages) exllamav3 exllamav2 flash-attn tabby-api;
          default = tabby-api;
        };

        devShells = {
          default = pkgs.mkShell {
            inputsFrom = [ pkgs.python3Packages.exllamav3 pkgs.python3Packages.exllamav2];

            shellHook = ''
              export CUDA_HOME="${pkgs.cudaPackages.cuda_nvcc}"
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
                pkgs.cudaPackages.cuda_cudart
                pkgs.cudaPackages.libcublas
                pkgs.cudaPackages.libcusparse
                pkgs.cudaPackages.libcusolver
                pkgs.cudaPackages.libcurand
                pkgs.stdenv.cc.cc.lib
              ]}:$LD_LIBRARY_PATH"
              export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0;12.0"

              echo "ExLlamaV2 development environment"
              echo "To install in development mode: pip install -e ."
              echo "To run tests: python test_inference.py -m <path_to_model> -p 'Once upon a time,'"
            '';
          };

          rust-deps = pkgs.mkShell {
            packages = with pkgs; [
              rustc
              cargo
              rustfmt
              clippy
            ];

            shellHook = ''
              echo "Rust development environment for Rust-based Python packages"
              echo "rustc version: $(rustc --version)"
              echo "cargo version: $(cargo --version)"
              echo ""
              echo "To generate Cargo.lock for kbnf:"
              echo "  cd /tmp && git clone https://github.com/Dan-wanna-M/kbnf.git"
              echo "  cd kbnf && git checkout v0.4.2-python"
              echo "  cargo generate-lockfile"
              echo "  cp Cargo.lock ${toString ./.}/pkgs/kbnf/"
              echo ""
              echo "To generate Cargo.lock for general-sam:"
              echo "  pip download --no-deps general-sam==1.0.0"
              echo "  tar xzf general_sam-1.0.0.tar.gz"
              echo "  cd general_sam-1.0.0"
              echo "  cargo generate-lockfile"
              echo "  cp Cargo.lock ${toString ./.}/pkgs/general-sam/"
            '';
          };
        };
      }
    );
}
