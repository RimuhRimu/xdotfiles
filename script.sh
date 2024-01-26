#!/bin/bash

# Store the current working directory
CWD=$(pwd)

# Define the error handling function
handle_error() {
	echo "An error occurred on line \\$1. Exiting..."
	exit 1
}

# Set up the error trap
trap 'handle_error $LINENO' ERR

# Prompt the user to choose the installation type
echo "Choose your installation type:"
echo "1. Full environment installation"
echo "2. Terminal-based tools only"
read -p "Enter your choice (1 or 2): " install_choice

# Install necessary packages for both installation types
echo "Starting up installation, necessary packages"
cd
mkdir -p dev/cloned
cd dev/cloned

sudo pacman -Syu
sudo pacman -S --needed base-devel git rustup
echo "Installing rustup..."
rustup default stable

echo "Starting installation of paru..."
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
echo "Paru installed successfully"

# Define the function for the full environment installation
install_full_environment() {
	sleep 5
	echo "Installing Xmonad"
	paru -S xorg-server xorg-apps xorg-xinit xorg-xmessage libx11 libxft libxinerama libxrandr libxss curl gcc gmp make ncurses doxygen

	echo "Proceeding to install ghcup and ghc haskell"
	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

	mkdir -p ~/.local/bin
	mkdir -p ~/.config/xmonad
	cd ~/.config/xmonad

	git clone https://github.com/xmonad/xmonad
	git clone https://github.com/xmonad/xmonad-contrib

	/home/$USER/.ghcup/bin/ghcup install stack
	/home/$USER/.ghcup/bin/stack install

	echo "Installing several packages..."
	paru -S fish deadd-notification-center neovim neofetch firefox kitty bat ranger zathura ulauncher ttf-fira-code starship picom discord eww otf-cascadia-code noto-fonts vlc lsd zoxide btop rofi chrony betterlockscreen feh redshift xautolock python-pillow xinit-xsession otf-font-awesome jq python-pip noto-fonts-emoji wmctrl asciiquarium playerctl brightnessctl todotxt notify-send.sh gtk-engine-murrine dsniff nmap arpfox yarn npm dropbox copyq
	echo "Packages installed successfully"

	curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

	fish -c omf install bass

	cd $CWD
	mkdir ~/wallpapers
	cp ./wallpapers/wall.jpg ~/wallpapers/

	betterlockscreen -u ~/wallpapers/wall.jpg

	# Backup the existing ~/.config/ directory
	mv ~/.config/ ~/.config.backup/

	# Create symbolic links to the config files
	for file in ~/path/to/config/*; do
		ln -s $file ~/.config/
	done

	# Create a symbolic link to the bin directory
	ln -s ~/path/to/bin ~/.local/bin

	echo "Installing nvim configs"
	git clone https://github.com/rimuhrimu/mylazyconfig ~/.config/nvim

	echo "Installing Tokyo-Night-GTK-Theme"
	git clone https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme ~/dev/cloned/tokyo-theme
	cd ~/dev/cloned/tokyo-theme
	sudo cp -r ./themes/* /usr/share/themes/
	cp -r ./themes/Tokyonight-Moon-BL/gtk-4.0/* ~/.config/gtk-4.0/

	cp -r ./config/* ~/.config/

	echo "Installing ranger plugins"
	git clone https://github.com/cdump/ranger-devicons2 ~/.config/ranger/plugins/devicons2
	git clone https://github.com/jchook/ranger-zoxide.git ~/.config/ranger/plugins/zoxide
}

# Define the function for the terminal-based tools installation
install_terminal_tools() {
	cd $CWD
	# Install terminal-based tools
	echo "Installing several packages..."
	paru -S fish neovim neofetch kitty bat ranger zathura starship lsd zoxide btop chrony feh redshift xautolock brightnessctl python-pillow xinit-xsession jq python-pip wmctrl asciiquarium playerctl todotxt notify-send.sh gtk-engine-murrine dsniff nmap arpfox yarn npm dropbox copyq
	echo "Packages installed successfully"

	# Install oh-my-fish
	curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

	# Install bass plugin for fish
	fish -c omf install bass

	# Install nvm
	echo "Installing nvm"
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

	mv ~/.config/ ~/.config.backup/
	cp -r ./config/* ~/.config/
	cp -r ./bin ~/.local/bin
	echo "Installing nvim configs"
	git clone https://github.com/rimuhrimu/mylazyconfig ~/.config/nvim

}

# Execute the chosen installation type
case $install_choice in
1)
	install_full_environment
	;;
2)
	install_terminal_tools
	;;
*)
	echo "Invalid choice. Exiting..."
	exit 1
	;;
esac

# If we reach this point, everything was successful
echo "Setup complete!"
