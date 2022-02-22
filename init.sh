export DOTFILES=$(dirname $BASH_SOURCE)

for file in $DOTFILES/global/*.sh
do source $file
done
