{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    booktheme = {
      url = "github:getzola/book";
      flake = false;
    };
    godot_src = {
      url = "github:itepastra/godot";
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
            self.packages."x86_64-linux".godot
            pkgs.blender
            pkgs.inkscape
            (pkgs.writeScriptBin "export_images" ''
              find -type d -not -path "./godot_assets" -exec mkdir -p -- "./godot_assets/{}" \;
              for filename in **/*.svg; do
                basename="''${filename%.svg}"
                inkscape "$filename" --export-filename="godot_assets/''${basename}.png"
              done
            '')
          ];
        };
      packages."x86_64-linux" =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
          fs = pkgs.lib.fileset;
        in
        rec {
          godot = pkgs.callPackage ./godot.nix { inherit (inputs) godot_src; };

          default = pkgs.stdenv.mkDerivation {
            name = "Qubit Quilt website";
            src = math-rendered;

            buildPhase = ''
              cp ${game}/qubit-quilt.audio.position.worklet.js \
                 ${game}/qubit-quilt.audio.worklet.js \
                 ${game}/qubit-quilt.js \
                 ${game}/qubit-quilt.pck \
                 ${game}/qubit-quilt.side.wasm \
                 ${game}/qubit-quilt.wasm .
            '';

            installPhase = ''
              mkdir -p $out
              cp -r . $out
              cp ${./assets/favicon.png} $out/favicon.png
              cp -r ${./website/static} $out/static
            '';
          };
          templates =
            let
              template =
                type: threads: dlink:
                pkgs.stdenv.mkDerivation {
                  name = "Godot-Templates-${type}-${if threads then "threads" else "nothreads"}${
                    if dlink then "-dlink" else ""
                  }";
                  nativeBuildInputs = [
                    pkgs.which
                    pkgs.emscripten
                    pkgs.pkg-config
                    pkgs.scons
                  ];

                  src = inputs.godot_src;

                  SOURCE_DATE_EPOCH = 315532801;

                  buildPhase = ''
                    export HOME=$(mktemp -d)
                    mkdir -p $HOME/.local/share/godot

                    # Patch timestamps before build, just in case
                    find . -type f -exec touch -d "@315532801" {} +

                    scons platform=web target=template_${type} threads=${if threads then "yes" else "no"} ${
                      if dlink then "dlink_enabled=yes" else ""
                    }
                  '';

                  installPhase = ''
                    mkdir -p $out
                    mv bin/godot.web.template_${type}.wasm32${if threads then "" else ".nothreads"}${
                      if dlink then ".dlink" else ""
                    }.zip $out/web_${if dlink then "dlink_" else ""}${if threads then "" else "nothreads_"}${type}.zip
                  '';
                };
            in
            {
              nothreads-debug = template "debug" false false;
              nothreads-release = template "release" false false;
              threads-debug = template "debug" true false;
              threads-release = template "release" true false;
              nothreads-debug-dlink = template "debug" false true;
              nothreads-release-dlink = template "release" false true;
              threads-debug-dlink = template "debug" true true;
              threads-release-dlink = template "release" true true;
            };
          game =
            let
              system = "x86_64-linux";
            in
            pkgs.stdenv.mkDerivation {
              name = "Qubit Quilt";
              nativeBuildInputs = [
                self.packages.${system}.godot
                pkgs.unzip
                pkgs.inkscape
                pkgs.fontconfig
              ];

              src = fs.toSource {
                root = ./.;
                fileset = fs.union (fs.difference (fs.difference ./qubit-quilt (fs.maybeMissing ./qubit-quilt/.godot)) (fs.maybeMissing ./qubit-quilt/export)) ./assets;
              };

              buildPhase = ''
                export HOME=$(pwd)
                pushd ./assets
                for filename in *.svg; do
                  basename="''${filename%.svg}"
                  inkscape "$filename" --export-filename="godot_assets/''${basename}.png"
                  echo "converted $filename to png"
                done
                popd
                mkdir -p $HOME/.local/share/godot/export_templates/4.4.2.rc
                pushd $HOME/.local/share/godot/export_templates/4.4.2.rc
                cp ${self.packages.${system}.templates.nothreads-debug-dlink}/* .
                cp ${self.packages.${system}.templates.nothreads-release-dlink}/* .
                popd
                pushd qubit-quilt
                ln -s ../assets/godot_assets assets
                godot --headless --import
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
          ssg = pkgs.stdenv.mkDerivation {
            name = "Qubit Quilt SSG";

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
          math-rendered = pkgs.stdenv.mkDerivation {
            pname = "html-math-renderer";
            version = "1.0";

            src = ssg;

            buildInputs = [
              pkgs.nodejs
              pkgs.nodePackages.katex
            ];

            buildPhase = ''
              mkdir -p $out
              cp ${./render-math.js} ./render-math.js
              node ./render-math.js $src $out
            '';

            installPhase = ''
              echo "Files written to $out"
            '';
          };
        };
    };
}
