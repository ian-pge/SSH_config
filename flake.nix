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

  outputs = {nixpkgs, home-manager, ... }:
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

            programs.fzf = {
                enable = true;
                enableZshIntegration = true;
            };

            programs.bat = {
                enable = true;
            };

            # Activate Home Manager's ZSH integration
            programs.zsh = {
              sessionVariables = {
                LANG = "en_US.UTF-8";
              };
              enable = true;
              enableCompletion = true;
                      plugins = [
                            { name = "zsh-vi-mode";
                              src  = pkgs.zsh-vi-mode;
                              file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
                            }
                            { name = "fast-syntax-highlighting";
                              src  = pkgs.zsh-fast-syntax-highlighting;
                              file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
                            }
                            { name = "zsh-autosuggestions";
                              src  = pkgs.zsh-autosuggestions;
                              file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
                            }
                            { name = "fzf-tab";
                              src  = pkgs.zsh-fzf-tab;
                              file = "share/fzf-tab/fzf-tab.plugin.zsh";
                            }
                ];
              shellAliases = {
                build-config = "nix build .#homeConfigurations.zed.activationPackage --extra-experimental-features flakes --extra-experimental-features nix-command --out-link ~/result && ~/result/activate";
              };
            };
            programs.oh-my-posh = {
                    enable = true;
                    enableZshIntegration = true;
                    settings =  {
                        "palette" = {
                          "blue"      = "#8AADF4";
                          "closer"    = "p:os";
                          "green"     = "#a6da95";
                          "lavender"  = "#B7BDF8";
                          "mauve"     = "#c6a0f6";
                          "os"        = "#ACB0BE";
                          "peach"     = "#F5A97F";
                          "pink"      = "#F5BDE6";
                          "sapphire"  = "#7dc4e4";
                          "yellow"    = "#eed49f";
                          "sky"       = "#91d7e3";
                        };
                        "transient_prompt" = {
                          "template"   = "{{now | date \"15:04\"}} ";
                          "foreground" = "p:yellow";
                          "background" = "transparent";
                        };
                        "blocks" = [
                          {
                            "type"      = "prompt";
                            "alignment" = "left";
                            "newline"   = true;
                            "segments" = [
                              {
                                "template"   = "{{.Icon}}  ";
                                "foreground" = "p:sky";
                                "type"       = "os";
                                "style"      = "plain";
                              }
                              {
                                "template"   = "{{.UserName }}@{{ .HostName }} ";
                                "foreground" = "p:blue";
                                "type"       = "session";
                                "style"      = "plain";
                              }
                              {
                                "properties" = {
                                  "folder_icon" = "..\ue5fe..";
                                  "home_icon"   = "~";
                                  "style"       = "agnoster_full";
                                };
                                "template"   = "{{ .Path }} ";
                                "foreground" = "p:pink";
                                "type"       = "path";
                                "style"      = "plain";
                              }
                              {
                                "properties" = {
                                  "branch_icon"          = "\ue725 ";
                                  "cherry_pick_icon"     = "\ue29b ";
                                  "commit_icon"          = "\uf417 ";
                                  "fetch_status"         = false;
                                  "fetch_upstream_icon"  = false;
                                  "merge_icon"           = "\ue727 ";
                                  "no_commits_icon"      = "\uf0c3 ";
                                  "rebase_icon"          = "\ue728 ";
                                  "revert_icon"          = "\uf0e2 ";
                                  "tag_icon"             = "\uf412 ";
                                };
                                "template"   = "{{ .HEAD }} ";
                                "foreground" = "p:lavender";
                                "type"       = "git";
                                "style"      = "plain";
                              }
                            ];
                          }
                          {
                            "type"      = "prompt";
                            "alignment" = "left";
                            "newline"   = true;
                            "segments" = [
                              {
                                "template"             = "❯";
                                "type"                 = "text";
                                "style"                = "plain";
                                "foreground_templates" = [
                                  "{{if gt .Code 0}}red{{end}}"
                                  "{{if eq .Code 0}}green{{end}}"
                                ];
                              }
                            ];
                          }
                          {
                            "type"      = "rprompt";
                            "alignment" = "right";
                            "segments" = [
                              {
                                "properties" = {
                                  "always_enabled" = true;
                                  "style"          = "round";
                                };
                                "template"   = "{{ .FormattedMs }} ";
                                "foreground" = "p:peach";
                                "type"       = "executiontime";
                                "style"      = "plain";
                              }
                            ];
                          }
                        ];
                        "version"     = 3;
                        "final_space" = true;
                      };
                };

            # Insert your custom snippet here
            programs.zsh.initExtra = ''
              . "$HOME/.nix-profile/etc/profile.d/nix.sh"
              export TERM=xterm-256color
              bindkey -v
              if [ ! -f ~/.zshrc.local ]; then
                touch ~/.zshrc.local
              fi
              source ~/.zshrc.local
            '';
          }
        ];
      };
    };
}
