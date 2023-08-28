#!/bin/bash
set -ex
mkdir -p ~/etc
cp -n /etc/makepkg.conf ~/etc || true
sudo sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j4"/g' /etc/makepkg.conf
cp -n /etc/pacman.conf ~/etc || true
sudo sed -i 's/#Color/Color/g' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
sudo pacman -S --needed ly git base-devel pacman-contrib inetutils polkit sway swaybg swaylock swayidle xdg-desktop-portal-wlr j4-dmenu-desktop qt5ct gnome-themes-extra ttf-hack xcursor-comix archlinux-wallpaper brightnessctl grim slurp copyq network-manager-applet neovim neofetch alacritty meld zsh grml-zsh-config chezmoi rsync tmux man-db man-pages yt-dlp vlc firefox pcmanfm-gtk3 lximage-qt qt5-imageformats virtualbox virtualbox-host-modules-arch dbeaver remmina freerdp
cp -n /etc/environment ~/etc || true
grep -qxF "XDG_CURRENT_DESKTOP=sway" /etc/environment || echo "XDG_CURRENT_DESKTOP=sway" | sudo tee -a /etc/environment
grep -qxF "QT_QPA_PLATFORM=wayland" /etc/environment || echo "QT_QPA_PLATFORM=wayland" | sudo tee -a /etc/environment
grep -qxF "QT_QPA_PLATFORMTHEME=qt5ct" /etc/environment || echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment
for arg in "$@"; do
	if [ "$arg" == "ssh" ]; then
		sudo pacman -S --needed openssh
		sudo systemctl enable sshd.service
	fi
	if [ "$arg" == "mouse" ]; then
		grep -qxF "WLR_NO_HARDWARE_CURSORS=1" /etc/environment || echo "WLR_NO_HARDWARE_CURSORS=1" | sudo tee -a /etc/environment
	fi
done
sudo systemctl disable lightdm.service
sudo systemctl enable ly.service
sudo systemctl enable paccache.timer
mkdir -p ~/etc/ly
cp -n /etc/ly/config.ini ~/etc/ly || true
sudo sed -i 's/#animate = false/animate = true/g' /etc/ly/config.ini
sudo sed -i 's/#animation = 0/animation = 1/g' /etc/ly/config.ini
mkdir -p ~/etc/systemd
cp -n /etc/systemd/logind.conf ~/etc/systemd || true
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
mkdir -p ~/screenshots
if [ "$SHELL" != "/bin/zsh" ]; then
	chsh -s /bin/zsh
fi
mkdir -p ~/aur
pushd ~/aur
if [ ! -d "paru" ]; then
	git clone https://aur.archlinux.org/paru.git
	pushd ~/aur/paru
	makepkg -si
	popd
fi
popd
mkdir -p ~/.icons/default
paru -S --needed swaync nwg-look google-chrome
chezmoi init --apply simonfogliato
