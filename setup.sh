#!/bin/bash

set -e

# Ensure LD_LIBRARY_PATH is unset
unset LD_LIBRARY_PATH

# Check if Nix is already installed
if ! command -v nix >/dev/null 2>&1; then
  echo "Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
else
  echo "Nix already installed, skipping installation."
fi

# Source Nix profile if it's not already sourced
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  echo "Sourcing Nix profile..."
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# Only build and activate if result doesn't exist
if [ ! -e "$HOME/result" ]; then
  echo "Building flake..."
  nix build .#homeConfigurations.zed.activationPackage \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    --out-link "$HOME/result"
fi

echo "Activating configuration..."
"$HOME/result/activate"

# Set Zsh as the default shell only if it's not already
if [ "$(getent passwd "$(whoami)" | cut -d: -f7)" != "/bin/zsh" ]; then
  echo "Linking zsh binary to /bin/zsh..."
  sudo ln -sf "$HOME/.nix-profile/bin/zsh" /bin/zsh

  echo "Changing default shell for user to zsh..."
  sudo usermod -s /bin/zsh "$(whoami)"
fi

echo "Setup complete."
