#!/bin/bash
set -ex
arch_backup() {
	if [ ! -e $HOME$1 ]; then
		mkdir -p $HOME`dirname $1` && cp -n $1 $_
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
sudo pacman -S --needed $(cat <<-PKGS
	ly git base-devel pacman-contrib inetutils man-db man-pages
	polkit sway swaybg swaylock swayidle xdg-desktop-portal-wlr j4-dmenu-desktop
	brightnessctl grim slurp copyq network-manager-applet
	qt5ct gnome-themes-extra ttf-hack xcursor-comix archlinux-wallpaper
	neovim neofetch alacritty meld zsh grml-zsh-config chezmoi rsync tmux
	vlc yt-dlp firefox pcmanfm-gtk3 lximage-qt qt5-imageformats
	virtualbox virtualbox-host-modules-arch
	dbeaver remmina freerdp
PKGS
)
arch_backup /etc/environment
arch_environment "XDG_CURRENT_DESKTOP=sway"
arch_environment "QT_QPA_PLATFORM=wayland"
arch_environment "QT_QPA_PLATFORMTHEME=qt5ct"
while [ $# -gt 0 ]; do
	case $1 in
		mouse)
			arch_environment "WLR_NO_HARDWARE_CURSORS=1"
			;;
		ssh)
			sudo pacman -S --needed openssh
			sudo systemctl enable sshd.service
			;;
	esac
	shift
done
sudo systemctl disable lightdm.service
sudo systemctl enable ly.service
sudo systemctl enable paccache.timer
arch_backup /etc/ly/config.ini
sudo sed -i 's/#animate = false/animate = true/g' /etc/ly/config.ini
sudo sed -i 's/#animation = 0/animation = 1/g' /etc/ly/config.ini
arch_backup /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
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
paru -S --needed $(cat <<-PKGS
	swaync nwg-look
	google-chrome
PKGS
)
nwg-look -a
mkdir -p $HOME/screenshots
