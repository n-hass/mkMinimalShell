# Usage

Generally, you just need to apply the overlay of the output of this flake onto your nixpkgs in your project's flake.

```
    let
        pkgs = import nixpkgs {
          inherit "aarch64-darwin";
          overlays = [ mkminimalshell.overlay ];
        };
      in
      {
        devShell = pkgs.mkMinimalShell {
          packages = with pkgs; [ ];
          env = { MY_ENV_VAR = "3"; };
          shellHook = ''
            echo "extra stuff happening here"
          '';
        };
```

This could look something like this in full:

```
{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    mk-minimal-shell.url = "github:n-hass/mkminimalshell";
  };

  outputs = { self, nixpkgs, flake-utils, mk-minimal-shell }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ mk-minimal-shell.overlay ];
        };
      in
      {
        devShell = pkgs.mkMinimalShell {

          buildInputs = with pkgs; [
            jdk21
            gradle
            cargo
          ];

          env = {
            RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          };

          shellHook = ''
            if [ -n "$IN_NIX_SHELL" ] && [ -z "$DIRENV_DIR" ] && which finger >/dev/null 2>&1; then
              TARGET_SHELL=$(finger $USER | awk '/Shell:/ {print $NF}')
              exec $TARGET_SHELL
            else
              echo "Unknown environment loader - use direnv or 'nix develop'"
            fi
          '';
        };
      }
    );
}
```

