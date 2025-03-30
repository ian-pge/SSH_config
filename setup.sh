#!/bin/bash

echo "Installing Nix..."
sh <(curl -L https://nixos.org/nix/install) --no-daemon

echo "Sourcing Nix profile..."
. /home/zed/.nix-profile/etc/profile.d/nix.sh

echo "Building flake..."
nix build .#homeConfigurations.zed.activationPackage \
  --extra-experimental-features flakes \
  --extra-experimental-features nix-command \
  --out-link ~/result

echo "Activating configuration..."
~/result/activate

echo "Linking zsh binary to /bin/zsh..."
sudo ln -sf ~/.nix-profile/bin/zsh /bin/zsh

echo "Changing default shell for user 'zed' to zsh..."
sudo usermod -s /bin/zsh $(whoami)

echo "Setup complete."
