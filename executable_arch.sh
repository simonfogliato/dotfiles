#!/bin/bash
set -ex
arch_backup() {
	if [ ! -e $HOME/arch/$1 ]; then
		mkdir -p $HOME/arch/`dirname $1` && cp -n $1 $_
	fi
}
arch_environment() {
	grep -qxF "$1" /etc/environment || echo "$1" | sudo tee -a /etc/environment
}
arch_backup /etc/makepkg.conf
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j4"/g' /etc/makepkg.conf
arch_backup /etc/pacman.conf
sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
sudo pacman -Syu --needed $(cat <<-PKGS
	ly git base-devel pacman-contrib inetutils man-db man-pages reflector
	polkit sway swaybg swaylock swayidle xdg-desktop-portal-wlr fuzzel
	brightnessctl grim slurp copyq network-manager-applet
	qt5ct gnome-themes-extra ttf-hack ttf-hack-nerd xcursor-comix archlinux-wallpaper
	zsh grml-zsh-config lsd awesome-terminal-fonts bat bat-extras
	neovim neofetch alacritty meld chezmoi rsync tmux ranger ncdu zip unzip
	vlc yt-dlp firefox pcmanfm-gtk3 gvfs eog
	virtualbox virtualbox-host-modules-arch
	dbeaver remmina freerdp
PKGS
)
arch_backup /etc/pacman.d/mirrorlist
arch_backup /etc/xdg/reflector/reflector.conf
sudo sed -i "s/# --country France,Germany/--country 'Canada,United States'/g" /etc/xdg/reflector/reflector.conf
sudo systemctl enable ly.service
sudo systemctl enable paccache.timer
sudo systemctl enable reflector.timer
arch_backup /etc/environment
arch_environment "XDG_CURRENT_DESKTOP=sway"
arch_environment "QT_QPA_PLATFORM=wayland"
arch_environment "QT_QPA_PLATFORMTHEME=qt5ct"
arch_environment "EDITOR=nvim"
arch_environment "VISUAL=nvim"
arch_backup /etc/ly/config.ini
sudo sed -i 's/#animate = false/animate = true/g' /etc/ly/config.ini
sudo sed -i 's/#animation = 0/animation = 1/g' /etc/ly/config.ini
arch_backup /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
arch_backup /usr/share/qt5ct/colors/darker.conf
sudo sed -i 's/#ff12608a,/#ff00aa00,/g' /usr/share/qt5ct/colors/darker.conf
if [ "$SHELL" != "/bin/zsh" ]; then
	chsh -s /bin/zsh
fi
mkdir -p $HOME/aur
pushd $HOME/aur
if [ ! -d $HOME/aur/paru ]; then
	git clone https://aur.archlinux.org/paru.git
	pushd $HOME/aur/paru
	makepkg -si
	popd
fi
popd
paru -Syu --needed $(cat <<-PKGS
	swaync nwg-look beautyline
	google-chrome
PKGS
)
nwg-look -a
mkdir -p $HOME/screenshots
while [ $# -gt 0 ]; do
	case $1 in
		mouse)
			arch_environment "WLR_NO_HARDWARE_CURSORS=1"
			;;
		ssh)
			sudo pacman -Syu --needed openssh
			sudo systemctl enable sshd.service
			;;
		print)
			sudo pacman -Syu --needed cups cups-filters system-config-printer
			paru -Syu --needed samsung-unified-driver
			;;
		uefi)
			sudo pacman -Syu --needed fwupd
			fwupdmgr refresh
			fwupdmgr get-updates
			fwupdmgr update
			;;
	esac
	shift
done
