{ authentik-src
, authentikPoetryOverrides
, defaultPoetryOverrides
, lib
, mkPoetryEnv
, python312
}:

let
  python = python312.override {
    self = python;
    packageOverrides = final: prev: {
      wheel = prev.wheel.overridePythonAttrs (oA: rec {
        version = "0.45.0";
        src = oA.src.override (oA: {
          rev = "refs/tags/${version}";
          hash = "sha256-SkviTE0tRB++JJoJpl+CWhi1kEss0u8iwyShFArV+vw=";
        });
      });
    };
  };
in
mkPoetryEnv {
  projectDir = authentik-src;
  inherit python;
  overrides = [
    defaultPoetryOverrides
  ] ++ authentikPoetryOverrides;
  groups = ["main"];
  checkGroups = [];
  # workaround to remove dev-dependencies for the current combination of legacy
  # used by authentik and poetry2nix's behavior
  pyproject = builtins.toFile "patched-pyproject.toml" (lib.replaceStrings
    ["tool.poetry.dev-dependencies"]
    ["tool.poetry.group.dev.dependencies"]
    (builtins.readFile "${authentik-src}/pyproject.toml")
  );
}
