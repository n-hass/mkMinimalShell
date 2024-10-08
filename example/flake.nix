{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mk-minimal-shell.url = "github:n-hass/mkminimalshell";
  };

  outputs = { self, nixpkgs, mk-minimal-shell }:
  let
    systems = [ "x86_64-linux" "aarch64-darwin" ];

    forEachSystem = system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ mk-minimal-shell.overlay ];
      };
    in {
      default = pkgs.mkMinimalShell {
        packages = with pkgs; [
          rustc
          cargo
          rust-analyzer
        ];
        HOST_PATH = "this was a second tested val";
      };
    };

    devShells = builtins.foldl' (acc: system: acc // { "${system}" = forEachSystem system; }) {} systems;
  in
  {
    inherit devShells;
  };
}

