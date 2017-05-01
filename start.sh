#!/bin/bash

if [ $(whoami) != 'root' ]; then
	echo "Must be root to run $0"
	exit 1;
fi

echo "This script will check and install development and common packages used by keylabs in ubuntu machines. Use wisely and... enjoy :)"

if [ ! -f "/etc/apt/sources.list.d/pgdg.list" ]; then
	echo "Adding postgresql repository"
	echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	echo "Added psql repo"
fi

apt update

base_apps="git build-essential autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev zsh hfsprogs exfat-fuse exfat-utils gitg autojump vim postgresql libpq-dev"

apt install $base_apps -y

echo "Base installed :)"

echo "Making zsh the default terminal..."

chsh -s $(which zsh)

if [ ! -d ~/.oh-my-zsh ]; then
	echo "Installing OhMyZsh"
	sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
fi

echo "Copying zshrc configuration..."

if [ -f "~/.zshrc" ]; then
	echo "Backing up actual conf..."
	cp ~/.zshrc ~/.zshrc.backp
	echo "Done"
fi
cp zshrc ~/.zshrc
echo "Copied"

if [ ! -d ~/.rbenv ]; then
	echo "Installing Rbenv"
	git clone https://github.com/rbenv/rbenv.git ~/.rbenv
	cd ~/.rbenv && src/configure && make -C src
	# Our conf has this for zsh, added to bashrc just in case
	echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
	echo 'eval "$(rbenv init -)"' >> ~/.bashrc
	echo "Installing RubyBuild too..."
	git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
	echo "Installed Rbenv"
fi

if [ ! -d ~/.nvm ]; then
	echo "Installing NVM"
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
	echo "Installing node"
	nvm install node
	nvm use node
	nvm alias default node
	echo "Installing Yard and Bower"
	npm install yard -g
	npm install bower -g
	echo "done :)"
fi

export PATH="$HOME/.rbenv/bin:$PATH"

eval "$(rbenv init -)"

find_latest_ruby() {
	rbenv install -l | grep -v - | tail -1 | sed -e 's/^ *//'
}

echo "Installing and configuring ruby"
ruby_version="$(find_latest_ruby)"
rbenv install -s "$ruby_version"

rbenv global "$ruby_version"
rbenv shell "$ruby_version"

echo "Updating gems"
gem update --system

echo "Installing bundler"
gem install bundler

echo "Installing rails"
gem install rails

echo "And... done :)"
