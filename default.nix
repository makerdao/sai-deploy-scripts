# Default import pinned pkgs
{ pkgsSrc ? (import ./nix/pkgs.nix {}).pkgsSrc
, pkgs ? (import ./nix/pkgs.nix { inherit pkgsSrc dapptoolsOverrides; }).pkgs
, dapptoolsOverrides ? {}
, doCheck ? false
, githubAuthToken ? null
}: with pkgs;

let
  inherit (builtins) replaceStrings;
  inherit (lib) mapAttrs optionalAttrs id;
  # Get contract dependencies from lock file
  inherit (callPackage ./dapp2.nix {}) specs packageSpecs package;
  inherit (specs.this) deps;
  optinalFunc = x: fn: if x then fn else id;

  # Update GitHub repo URLs and add a auth token for private repos
  addGithubToken = spec: spec // (let
    url = replaceStrings
      [ "https://github.com" ]
      [ "https://${githubAuthToken}@github.com" ]
      spec.repo.url;
  in rec {
    repo = spec.repo // { inherit url; };
  });

  # Recursively add GitHub auth token to spec
  recAddGithubToken = spec: addGithubToken (spec // {
    deps = mapAttrs (_: recAddGithubToken) spec.deps;
  });

  # Create derivations from lock file data
  packages = packageSpecs (mapAttrs (_: spec:
    (optinalFunc (! isNull githubAuthToken) recAddGithubToken)
      (spec // {
        inherit doCheck;
        solc = solc-versions.solc_0_4_25;
        solcFlags = "--optimize --metadata";
      })
  ) deps);

in makerScriptPackage {
  name = "sai-deploy-scripts";

  # Specify files to add to build environment
  src = lib.sourceByRegex ./. [
    "bin" "bin/.*"
    "lib" "lib/.*"
    "libexec" "libexec/.*"
    "config" "config/.*"
  ];

  solidityPackages =
    (builtins.attrValues packages);
}
