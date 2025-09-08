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
    };
}
