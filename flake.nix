{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    booktheme = {
      url = "github:getzola/book";
      flake = false;
    };
    export_templates = {
      url = "https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_export_templates.tpz";
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
          qubit-quilt-game = pkgs.stdenv.mkDerivation {
            name = "qubit-quilt";
            nativeBuildInputs = [
              pkgs.godot
              pkgs.unzip
            ];

            src = fs.toSource {
              root = ./.;
              fileset = fs.union (fs.difference (fs.difference ./qubit-quilt (fs.maybeMissing ./qubit-quilt/.godot)) (fs.maybeMissing ./qubit-quilt/export)) ./assets;
            };

            buildPhase = ''
              export HOME=$(pwd)
              mkdir -p $HOME/.local/share/godot/export_templates/4.4.1.stable
              pushd $HOME/.local/share/godot/export_templates/4.4.1.stable
              unzip -j ${inputs.export_templates} \
                templates/web_dlink_nothreads_debug.zip \
                templates/web_nothreads_debug.zip \
                templates/web_dlink_nothreads_release.zip \
                templates/web_nothreads_release.zip
              popd
              pushd qubit-quilt
              mkdir export
              godot --verbose --headless --export-release Web export/qubit-quilt.html
              popd
            '';

            installPhase = ''
              mkdir -p $out
              pushd qubit-quilt
              cp export/* $out
              popd
            '';
          };
          qubit-quilt-site = pkgs.stdenv.mkDerivation {
            name = "qubit-quilt-site";

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
