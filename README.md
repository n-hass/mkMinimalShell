# Why?

When using Nix to create devShells for development on, say, a Rust or React/JavaScript project, nixpkgs `mkShell` uses `stdenv` in it its `mkDerivation`, which brings in A LOT of uneeded packages (like a full C compiler) to the sum of ~300MB and alters a bunch of environment variables.


Using a simple `devShell = pkgs.mkShell { };` with direnv will change all this on macOS:

```
direnv: export +AR +AS +CC +CONFIG_SHELL +CXX +HOST_PATH +IN_NIX_SHELL +LD +LD_DYLD_PATH +MACOSX_DEPLOYMENT_TARGET +NIX_BINTOOLS +NIX_BINTOOLS_WRAPPER_TARGET_HOST_aarch64_apple_darwin +NIX_BUILD_CORES +NIX_BUILD_TOP +NIX_CC +NIX_CC_WRAPPER_TARGET_HOST_aarch64_apple_darwin +NIX_CFLAGS_COMPILE +NIX_DONT_SET_RPATH +NIX_DONT_SET_RPATH_FOR_BUILD +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_IGNORE_LD_THROUGH_GCC +NIX_LDFLAGS +NIX_NO_SELF_RPATH +NIX_STORE +NM +PATH_LOCALE +RANLIB +SIZE +SOURCE_DATE_EPOCH +STRINGS +STRIP +TEMP +TEMPDIR +TMP +ZERO_AR_DATE +__darwinAllowLocalNetworking +__impureHostDeps +__propagatedImpureHostDeps +__propagatedSandboxProfile +__sandboxProfile +__structuredAttrs +buildInputs +buildPhase +builder +cmakeFlags +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +dontAddDisableDepTrack +mesonFlags +name +nativeBuildInputs +out +outputs +patches +phases +preferLocalBuild +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH ~TMPDIR ~XDG_DATA_DIRS
```

Using `mkMinimalShell` from this overlay will reduce this to:

```
direnv: export +IN_NIX_SHELL ~PATH ~TMPDIR ~XDG_DATA_DIRS
```

This is a work in progress and I'd still like to clean up some of the remnants of stdenv left in PATH - and I'm also aware that non-darwin systems may still have some other environment variables carry through. Please open an issue to document what should be unset / reverted from stdenv on your platform.

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

