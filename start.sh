#!/bin/bash

echo "This script will check and install development and common packages used by keylabs in ubuntu machines. Use wisely and... enjoy :)"

if [ ! -d /etc/apt/sources.list.d ]; then
	echo "Doesn't exists sources.list.d folder, creating..."
	sudo mkdir /etc/apt/sources.list.d
	echo "done"
fi

if ! grep -q "^deb .*postgresql" /etc/apt/sources.list /etc/apt/sources.list.d/*; then 
	echo "Not found Postgresql PPA, adding..." 
	sudo su -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list"
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
	echo "Added psql repo"
fi

if ! grep -q "^deb .*terminix" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
	echo "Not found Terminix (Tilix) PPA, adding cause it's AWESOME :)"
        sudo add-apt-repository ppa:webupd8team/terminix -y
fi

echo "Enter your password if apt ask for it"

sudo apt update
sudo apt upgrade -y

base_apps="git build-essential autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev zsh hfsprogs exfat-fuse exfat-utils gitg autojump vim postgresql libpq-dev libsqlite3-dev python3-pip python3-dev gcc tilix libssl-dev libffi-dev mosh"

# Run apt without checking nothing because apt it's idempotent :)
sudo apt install $base_apps -y

echo "Base installed :)"

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
fi

echo "add nvm to path"
# Add NVM to the path
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

echo "Installing node"
nvm install node
nvm use node
nvm alias default node
echo "Installing Yarn and Bower"
npm install -g yarn
npm install -g bower
echo "done :)"


# Add rbenv to PATH
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

echo "Making zsh the default terminal..."

echo "To turn zsh in your default terminal insert your password"
chsh -s $(which zsh)

if [ ! -d ~/.oh-my-zsh ]; then
	echo "Installing OhMyZsh"
	git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
fi

echo "Copying zshrc configuration..."

if [ -f "~/.zshrc" ]; then
	echo "Backing up actual conf..."
	cp ~/.zshrc ~/.zshrc.backp
	echo "Done"
fi
cp zshrc ~/.zshrc
echo "Copied"

echo "Install python deps"
echo "Upgrading pip"
sudo pip3 install --upgrade pip
echo "Installing stormssh"
sudo pip3 install --upgrade stormssh

echo "And... done :)"
