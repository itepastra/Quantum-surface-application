{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    {
      devShells."x86_64-linux".default =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in
        pkgs.mkShell {
          packages = [
            pkgs.dotnetCorePackages.dotnet_9.sdk
            pkgs.nuget
            pkgs.zola
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
            ];

            src = fs.toSource {
              root = ./website;
              fileset = fs.difference ./website (fs.maybeMissing ./website/public);
            };

            buildPhase = ''
              zola build --output-dir $out
            '';
          };
        };
    };
}
