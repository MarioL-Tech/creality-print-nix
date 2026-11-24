{
  description = "Creality’s 3D printing slicer";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  outputs = { nixpkgs, ... }: {
    packages.x86_64-linux = rec {
      creality-print = nixpkgs.legacyPackages.x86_64-linux.callPackage ./package.nix { };
      default = creality-print;
    };
  };
}
