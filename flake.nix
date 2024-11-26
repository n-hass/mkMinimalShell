{
  description = "An overlay providing mkMinimalShell";

  outputs = { self }:
    {
      overlay = final: prev:
        let
          stdenvMinimal = final.stdenvNoCC.override {
            cc = null;
            preHook = "";
            allowedRequisites = null;
            initialPath = final.lib.filter
              (a: final.lib.hasPrefix "coreutils" a.name)
              final.stdenvNoCC.initialPath;
            shell = "${final.bash}/bin/bash";
            extraNativeBuildInputs = [];
          };

          baseVarsToUnset = [
            "CONFIG_SHELL"
            "HOST_PATH"
            "MACOSX_DEPLOYMENT_TARGET"
            "NIX_BUILD_CORES"
            "NIX_BUILD_TOP"
            "NIX_CFLAGS_COMPILE"
            "NIX_DONT_SET_RPATH"
            "NIX_DONT_SET_RPATH_FOR_BUILD"
            "NIX_DONT_SET_RPATH_FOR_TARGET"
            "NIX_NO_SELF_RPATH"
            "NIX_STORE"
            "NIX_LDFLAGS"
            "SOURCE_DATE_EPOCH"
            "TEMP"
            "TEMPDIR"
            "TMP"
            "__darwinAllowLocalNetworking"
            "__impureHostDeps"
            "__propagatedImpureHostDeps"
            "__propagatedSandboxProfile"
            "__sandboxProfile"
            "__structuredAttrs"
            "buildInputs"
            "buildPhase"
            "builder"
            "cmakeFlags"
            "configureFlags"
            "depsBuildBuild"
            "depsBuildBuildPropagated"
            "depsBuildTarget"
            "depsBuildTargetPropagated"
            "depsHostHost"
            "depsHostHostPropagated"
            "depsTargetTarget"
            "depsTargetTargetPropagated"
            "doCheck"
            "doInstallCheck"
            "dontAddDisableDepTrack"
            "mesonFlags"
            "name"
            "nativeBuildInputs"
            "out"
            "outputs"
            "patches"
            "phases"
            "preferLocalBuild"
            "propagatedBuildInputs"
            "propagatedNativeBuildInputs"
            "shell"
            "shellHook"
            "stdenv"
            "strictDeps"
            "system"
          ];
        in
        {
          mkMinimalShell = args:
            let

              # Get all top-level attribute names in args.
              topLevelAttrNames = final.lib.attrNames args;

              # If `args.env` exists and is an attribute set, get its attribute names.
              envAttrNames = if final.lib.isAttrs (args.env or null) 
                then final.lib.attrNames args.env 
                else [];

              # Filter out variables that are in top-level args or args.env.
              filteredVarsToUnset = builtins.filter (var:
                !(final.lib.elem var topLevelAttrNames || final.lib.elem var envAttrNames)
              ) baseVarsToUnset;

              # Construct the new shell hook by unsetting filtered variables and adding any provided shellHook.
              controlledShellHook = ''
                ${final.lib.concatStringsSep " " (builtins.map (var: "unset ${var}") filteredVarsToUnset)}
                ${args.shellHook or ""}
              '';

              clearedAttributes = {
              };
            in
            final.mkShell.override { stdenv = stdenvMinimal; } (clearedAttributes // args // { shellHook = controlledShellHook; });
        };
    };
}
