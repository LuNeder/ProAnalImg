{
  description = "Software de Gerenciamento Interno do Emc2 no IFSC";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = {nixpkgs, systems, ...}: let
    inherit (nixpkgs.lib) genAttrs;
    forEachSystem = f: genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
  in {
    # nix develop -c zsh
    devShells = forEachSystem (pkgs: {
      default = pkgs.mkShell {
        packages = [
          (pkgs.julia_111.withPackages [
              "Images"
              "ImageInTerminal"
              #"ImageView" # Broken
              "TestImages"
              "FileIO"
              "Plots"
              "PlotThemes"
              "Gtk4"
            ])
          pkgs.gtk4
          pkgs.glib
          pkgs.patchelf
        ];
      };
    });
  };
}