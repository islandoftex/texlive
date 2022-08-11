{
  description = "TeX Live images";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
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
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            # install pre-commit into the shell environment
            pre-commit
            # ... and all its dependencies for the hooks
            git
            hadolint
            nixpkgs-fmt
            shellcheck
            shfmt
            # nixpkgs-fmt on other hand also depends on rust
            cargo
          ];
        };
      }
    );
}
