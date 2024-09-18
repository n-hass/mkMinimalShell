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
            initialPath = [final.coreutils];
            shell = "${final.bash}/bin/bash";
            extraNativeBuildInputs = [];
          };

          unsetVars = ''
            unset CONFIG_SHELL
            unset HOST_PATH
            unset MACOSX_DEPLOYMENT_TARGET
            unset NIX_BUILD_CORES
            unset NIX_BUILD_TOP
            unset NIX_CFLAGS_COMPILE
            unset NIX_DONT_SET_RPATH
            unset NIX_DONT_SET_RPATH_FOR_BUILD
            unset NIX_DONT_SET_RPATH_FOR_TARGET
            unset NIX_NO_SELF_RPATH
            unset NIX_STORE
            unset SOURCE_DATE_EPOCH
            unset TEMP
            unset TEMPDIR
            unset TMP
            unset __darwinAllowLocalNetworking
            unset __impureHostDeps
            unset __propagatedImpureHostDeps
            unset __propagatedSandboxProfile
            unset __sandboxProfile
            unset __structuredAttrs
            unset buildInputs
            unset buildPhase
            unset builder
            unset cmakeFlags
            unset configureFlags
            unset depsBuildBuild
            unset depsBuildBuildPropagated
            unset depsBuildTarget
            unset depsBuildTargetPropagated
            unset depsHostHost
            unset depsHostHostPropagated
            unset depsTargetTarget
            unset depsTargetTargetPropagated
            unset doCheck
            unset doInstallCheck
            unset dontAddDisableDepTrack
            unset mesonFlags
            unset name
            unset nativeBuildInputs
            unset out
            unset outputs
            unset patches
            unset phases
            unset preferLocalBuild
            unset propagatedBuildInputs
            unset propagatedNativeBuildInputs
            unset shell
            unset shellHook
            unset stdenv
            unset strictDeps
            unset system
          '';
        in
        {
          mkMinimalShell = args:
            let
              newShellHook = ''
                ${unsetVars}
                ${args.shellHook or ""}
              '';
            in
            final.mkShell.override { stdenv = stdenvMinimal; } (args // { shellHook = newShellHook; });
        };
    };
}
