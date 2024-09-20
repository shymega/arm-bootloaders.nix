{
  description = "A flake for embedded LK development (Android)";

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
    {
      devShells.x86_64-linux.arm-none-eabi =
        let
          arm-linux-androideabi = inputs.arm-bootloaders-nix.packages.${pkgs.system}.gcc-arm-linux-androideabi;
        in
        mkShell {
          name = "embedded-arm-lk-shell";
          buildInputs = [
            bear
            git
            glibc.static
            zlib.static
            arm-linux-androideabi
            gcc-arm-embedded
            pkgsCross.arm-embedded.buildPackages.binutils
            cmake
          ];
        };
        devShells.x86_64-linux.default = self.devShells.x86_64-linux.arm-none-eabi;
    };
}
