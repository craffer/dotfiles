# Use Make to automate installations and configurations, using these dotfiles
# based heavily on https://github.com/webpro/dotfiles/blob/master/Makefile
SHELL = /bin/zsh
DETECTED_OS := $(shell uname)

ifeq ($(detected_OS),Darwin)
	OS = macos
else
	OS = linux
endif

# install everything, based on what OS you're running
all: $(OS)

macos: sudo oh-my-zsh core-macos packages link

# get sudo access
sudo:
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# install oh-my-zsh if its not installed, and use our zshrc (not the default one)
oh-my-zsh:
	[ -d ~/.oh-my-zsh/ ] || sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

core-macos: brew git npm ruby defaults

packages: brew-packages cask-apps node-packages gems

link:
	install/link.zsh

# install homebrew, if not already installed
brew:
	type brew > /dev/null || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby

# install git
git: brew
	brew install git git-lfs

# install nvm and npm, TODO fix
npm:
	if ! [ -d $(NVM_DIR)/.git ]; then git clone https://github.com/creationix/nvm.git $(NVM_DIR); fi
	. $(NVM_DIR)/nvm.sh; nvm install --lts

# install ruby
ruby: brew
	brew install ruby

# install all brew formulas from our Brewfile
brew-packages: brew
	brew bundle --file=$(CURDIR)/install/Brewfile

# install all brew cask apps from our Caskfile, and VSCode extensions
cask-apps: brew
	brew bundle --file=$(CURDIR)/install/Caskfile
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

# install all global npm modules from our npmfile
node-packages: npm
	. $(NVM_DIR)/nvm.sh; npm install -g $(shell cat install/npmfile)

# install ruby gems from our Gemfile
gems: ruby
	export PATH="/usr/local/opt/ruby/bin:$PATH"; gem install $(shell cat install/Gemfile)

defaults: sudo
	other/.macos.zsh
