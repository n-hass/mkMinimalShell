{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mk-minimal-shell.url = "path:../";
  };

  outputs = { self, nixpkgs, mk-minimal-shell }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [mk-minimal-shell.overlay];
    };
  in {
    devShell.${system} = pkgs.mkMinimalShell {
      packages = with pkgs; [
        rustc
        cargo
        rust-analyzer
      ];
      HOST_PATH = "this was a second tested val";
    };
  };
}
