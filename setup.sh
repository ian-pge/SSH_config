#!/bin/bash

if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
  . ~/.nix-profile/etc/profile.d/nix.sh
fi

# Check if Nix is already installed
if ! command -v nix > /dev/null; then
  echo "Installing Nix..."
  sh <(curl -L https://nixos.org/nix/install) --no-daemon
else
  echo "Nix is already installed."
fi

# Source Nix profile if not already sourced
if [ -z "$NIX_PATH" ]; then
  echo "Sourcing Nix profile..."
  . ~/.nix-profile/etc/profile.d/nix.sh
fi

# Build and activate Home Manager configuration only if necessary
if [ ! -L ~/result ]; then
  echo "Building flake..."
  nix build .#homeConfigurations.zed.activationPackage \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    --out-link ~/result
  echo "Activating configuration..."
  ~/result/activate
else
  echo "Home Manager configuration already activated."
fi

# Link zsh binary to /bin/zsh if needed
if [ ! -f /bin/zsh ] || [ "$(readlink /bin/zsh)" != "~/.nix-profile/bin/zsh" ]; then
  echo "Linking zsh binary to /bin/zsh..."
  sudo ln -sf ~/.nix-profile/bin/zsh /bin/zsh
fi

# Change default shell for the current user if not already zsh
if [ "$(getent passwd $(whoami) | cut -d: -f7)" != "/bin/zsh" ]; then
  echo "Changing default shell for user to zsh..."
  sudo usermod -s /bin/zsh $(whoami)
fi

echo "Setup complete."
