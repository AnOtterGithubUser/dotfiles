# Install homebrew
sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install iterm2
sh "brew cask install iterm2"

# Install zsh and make it default bash
echo "Install zsh"
echo "-----------"
CURRENT_SHELL=$(basename "$SHELL")
if [[ $CURRENT_SHELL != "zsh" ]]; then
  echo "zsh is already the default bash"
else
  sh "brew install zsh"
  echo "Installed zsh version " $(zsh --version)
  sh "chsh -s $(which zsh)"
fi


# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
echo "Installed oh-my-zsh"

# Install powerlevel10k
POWERLEVEL10K_DIR="~/.powerlevel10k"
PLUGINS_DIR="~/.oh-my-zsh/custom/plugins"
mkdir $POWERLEVEL10K_DIR
git -C $POWERLEVEL10K_DIR clone --depth=1 https://github.com/romkatv/powerlevel10k.git
mkdir -p $PLUGINS_DIR

# Install plugins
git -C $PLUGINS_DIR clone https://github.com/zsh-users/zsh-autosuggestions
git -C $PLUGINS_DIR clone https://github.com/zsh-users/zsh-syntax-highlighting

# Install anaconda
bash -c "$(curl -fsSL https://repo.anaconda.com/archive/Anaconda3-2020.07-MacOSX-x86_64.sh)"

# Symlinks
for obj in $(pwd)/*; do
  if [[ -d $obj ]];then
    for file in $obj/*;do
      ln -sfv "$file" ~
    done
  fi
done

#TODO: Integration with dotfiles manager
#TODO: Shell scripts to install applications and tools





