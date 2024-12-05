{
  description = "An overlay providing mkMinimalShell";

  outputs =
    { self }:
    {
      overlay =
        final: prev:
        let
          stdenvMinimal = final.stdenvNoCC.override {
            cc = null;
            preHook = "";
            allowedRequisites = null;
            initialPath = final.lib.filter (
              a: final.lib.hasPrefix "coreutils" a.name
            ) final.stdenvNoCC.initialPath;
            shell = "${final.bash}/bin/bash";
            extraNativeBuildInputs = [ ];
          };

          baseVarsToUnset = [
            "CONFIG_SHELL"
            "DEVELOPER_DIR"
            "HOST_PATH"
            "MACOSX_DEPLOYMENT_TARGET"
            "NIX_APPLE_SDK_VERSION"
            "NIX_BUILD_CORES"
            "NIX_BUILD_TOP"
            "NIX_CFLAGS_COMPILE"
            "NIX_DONT_SET_RPATH"
            "NIX_DONT_SET_RPATH_FOR_BUILD"
            "NIX_DONT_SET_RPATH_FOR_TARGET"
            "NIX_NO_SELF_RPATH"
            "NIX_STORE"
            "NIX_LDFLAGS"
            "SDKROOT"
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
            "extraUnsetEnv"
            "keepEnv"
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
          mkMinimalShell =
            with builtins;
            args:
            let
              userUnsetVars = args.extraUnsetEnv or [ ];
              userKeepVars = args.keepEnv or [ ];
              topLevelAttrNames = attrNames args;
              userEnv = args.env or { };
              envAttrNames = attrNames userEnv;

              filteredBaseVarsToUnset = filter (var: !(elem var envAttrNames) && !(elem var userKeepVars)) (
                baseVarsToUnset ++ topLevelAttrNames
              );

              controlledShellHook = ''
                ${concatStringsSep "\n" (map (var: "unset ${var}") filteredBaseVarsToUnset)}
                ${concatStringsSep "\n" (map (var: "unset ${var}") userUnsetVars)}
                ${concatStringsSep "\n" (
                  attrValues (mapAttrs (name: value: "${name}='${toString value}'") userEnv)
                )}
                ${args.shellHook or ""}
              '';
            in
            final.mkShell.override { stdenv = stdenvMinimal; } (args // { shellHook = controlledShellHook; });
        };
    };
}
