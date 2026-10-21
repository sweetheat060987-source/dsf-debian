{
  description = "Host tools for signing and uploading Ubuntu source packages";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }: {
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            debian-devscripts
            dput-ng
            gnupg
          ];

          shellHook = ''
            # Release checks must use today's date, not Nix's build epoch.
            unset SOURCE_DATE_EPOCH
          '';
        };
      });
  };
}
