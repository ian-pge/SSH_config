{
  description = "Home Manager configuration with zsh and oh-my-posh";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations.myUser = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        configuration = { config, pkgs, ... }: {
          # Enable zsh as your default shell
          programs.zsh = {
            enable = true;
            # Add extra initialization for oh-my-posh
            initExtra = ''
              # Check if oh-my-posh is available and then initialize it.
              if command -v oh-my-posh >/dev/null; then
                # Use a theme file from the oh-my-posh package (adjust the theme as needed)
                eval "$(oh-my-posh init zsh --config ${pkgs.oh-my-posh}/share/oh-my-posh/themes/jandedobbeleer.omp.json)"
              fi
            '';
          };

          # Ensure oh-my-posh is installed in your environment
          home.packages = with pkgs; [
            oh-my-posh
          ];

          # Optionally, add any other configurations below...
        };
      };
    };
}
