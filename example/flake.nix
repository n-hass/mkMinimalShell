{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mk-minimal-shell.url = "github:n-hass/mkminimalshell";
  };

  outputs = { self, nixpkgs, mk-minimal-shell }:
  let
    pkgs.x86_64-linux = import nixpkgs {
      system = "x86_64-linux";
      overlays = [mk-minimal-shell.overlay];
    };

    pkgs.aarch64-darwin = import nixpkgs {
      system = "aarch64-darwin";
      overlays = [mk-minimal-shell.overlay];
    };

  in {
    devShell.aarch64-darwin = pkgs.aarch64-darwin.mkMinimalShell {
      packages = with pkgs.aarch64-darwin; [
        rustc
        cargo
        rust-analyzer
      ];
      HOST_PATH = "this was a second tested val";
    };

    devShell.x86_64-linux = pkgs.x86_64-linux.mkMinimalShell {
      packages = with pkgs.x86_64-linux; [
        rustc
        cargo
        rust-analyzer
      ];
      HOST_PATH = "this was a second tested val";
    };
  };
}
