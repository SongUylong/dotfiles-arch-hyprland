# Add user configurations here
# For HyDE to not touch your beloved configurations,
# we added 2 files to the project structure:
# 1. ~/.hyde.zshrc - for customizing the shell related hyde configurations
# 2. ~/.zshenv - for updating the zsh environment variables handled by HyDE // this will be modified across updates

#  Plugins 
# oh-my-zsh plugins are loaded  in ~/.hyde.zshrc file, see the file for more information

#  Aliases 
# Add aliases here

#  This is your file 
# Add your configurations here
# export EDITOR=nvim
export EDITOR=code

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:/home/uylong/.spicetify
