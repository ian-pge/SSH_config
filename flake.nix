{
  description = "Example flake for ZSH configuration with Home Manager";

  inputs = {
    # Nixpkgs: pick whichever branch/channel you like
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # Define a Home Manager configuration for a user named "zed".
      homeConfigurations.zed = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        modules = [
          {
            home.username = "zed";
            home.homeDirectory = "/home/zed";
            home.stateVersion = "24.11";

            home.packages = with pkgs; [
              nettools
            ];

            # Activate Home Manager's ZSH integration
            programs.zsh = {
              sessionVariables = {
                LANG = "en_US.UTF-8";
              };
              enable = true;
              autosuggestion.enable = true;
              syntaxHighlighting.enable = true;
              completionInit = "autoload -Uz compinit && compinit";
              shellAliases = {
                build-config = "nix build .#homeConfigurations.zed.activationPackage --extra-experimental-features flakes --extra-experimental-features nix-command --out-link ~/result && ~/result/activate";
              };
            };

            programs.oh-my-posh = {
              enable = true;
              enableZshIntegration = true;
              settings = builtins.fromJSON (builtins.readFile ./zsh_theme.json);
            };

            # Insert your custom snippet here
            programs.zsh.initExtra = ''
              . "$HOME/.nix-profile/etc/profile.d/nix.sh"
              export TERM=xterm-256color
              bindkey -v
            '';
          }
        ];
      };
    };
}
