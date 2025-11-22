{
  description = "TeX Live images";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              # install pre-commit into the shell environment
              pre-commit
              # ... and all its dependencies for the hooks
              hadolint
              nixpkgs-fmt
              shellcheck
              shfmt
              # nixpkgs-fmt on other hand also depends on rust
              cargo
            ];
          };
        };
      }
    );
}
