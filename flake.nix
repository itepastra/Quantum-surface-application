{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    booktheme = {
      url = "github:getzola/book";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    {
      devShells."x86_64-linux".default =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.mkShell {
          packages = [
            pkgs.zola
            pkgs.godot
            pkgs.blender
            pkgs.inkscape
          ];
        };
      packages."x86_64-linux" =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          fs = pkgs.lib.fileset;
        in
        rec {
          default = qubit-quilt-site;
          qubit-quilt-site = pkgs.stdenv.mkDerivation {
            name = "qubit-quilt";

            nativeBuildInputs = [
              pkgs.zola
              pkgs.git
            ];

            src = fs.toSource {
              root = ./website;
              fileset = fs.difference ./website (fs.maybeMissing ./website/public);
            };

            buildPhase = ''
              mkdir -p themes/book
              cp -r ${inputs.booktheme}/* themes/book
              zola build --output-dir $out
            '';
          };
        };
    };
}
