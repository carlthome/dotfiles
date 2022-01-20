# dotfiles
Until I learn about [home-manager](https://github.com/nix-community/home-manager) properly, this is some of my personal workstation shell configuration that I wish to sync between machines. To make it easy on myself, I'm only considering Bash.

- `global/` contains .bashrc config intended to be sourced into the shell by default by `source $HOME/git/carlthome/dotfiles/init.sh` in .bashrc
- `scripts/` contains ad-hoc scripts intended to be run in a shell on demand.
