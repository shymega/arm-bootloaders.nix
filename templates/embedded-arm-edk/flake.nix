{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    arm-bootloaders-nix.url = "github:shymega/arm-bootloaders.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
      };
    in
    with pkgs;
      rec {
        devShells.x86_64-linux.arm-none-eabi =
          let

            gcc = pkgs.pkgsCross.arm-embedded.buildPackages.gcc9;
            binutils = pkgs.pkgsCross.arm-embedded.buildPackages.binutils;
            toolchain = pkgs.buildEnv {
              name = "arm-embedded-toolchain";
              path = [ gcc binutils ];
            };
          in
          mkShell {
            name = "embedded-arm64-edk";
            buildInputs = [
              toolchain
            ];
          };
        devShells.x86_64-linux.default = self.devShells.x86_64-linux.arm-none-eabi;
      };
}
