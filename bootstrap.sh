# Install Nix.
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes and the new command-line interface.
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
