{
  description = "A collection of templates & packages for embedded ARM systems";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };
  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (pkgs.stdenv) mkDerivation;
        in
        with pkgs; {
          gcc-arm-linux-androideabi =
            mkDerivation {
              src = fetchgit {
                url = "https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9";
                rev = "bdb57364ad4941a344b6d6e22083762a7669c582";
                sha256 = "sha256-UB4/17cKtMYYLi1D5kDfWoEkTjdNtO+EPluJj9dv88Q=";
              };
              nativeBuildInputs = [ python3 autoPatchelfHook ];
              buildInputs = [ stdenv.cc.cc.lib ];
              dontBuild = true;
              dontStrip = true;
              dontConfigure = true;
              installPhase = ''
                mkdir -p $out
                cp -R * $out
                patchShebangs $out/bin/*
              '';
              preFixup = ''
                find $out -type f | while read f; do
                  patchelf "$f" > /dev/null 2>&1 || continue
                  patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) "$f" || true
                  patchelf --set-rpath ${lib.makeLibraryPath [ "$out" stdenv.cc.cc ]} "$f" || true
                done
              '';
              name = "gcc-arm-linux-androideabi";
            };
        });
      templates = {
        embedded-arm-edk = {
          path = ./templates/embedded-arm-edk;
          description = "A template for an embedded ARM EDK II system";
        };

        embedded-arm-lk = {
          path = ./templates/embedded-arm-lk;
          description = "A template for an embedded ARM LK system";
        };

        embedded-arm-u-boot = {
          path = ./templates/embedded-arm-u-boot;
          description = "A template for an embedded ARM U-Boot system";
        };
      };
    };
}
