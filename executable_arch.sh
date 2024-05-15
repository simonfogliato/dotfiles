#!/bin/bash
set -e
echo "arch.sh"
echo "arch.sh [options]"
echo "arch.sh mouse ssh print flameshot webex uefi vb vb-lts kvm docker"
set -x
arch_backup() {
	if [ ! -e "$HOME/arch$1" ]; then
		mkdir -p "$HOME/arch$(dirname "$1")" && cp -n "$1" "$_"
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
arch_backup /etc/pacman.d/mirrorlist
sudo pacman -Syu --needed reflector
arch_backup /etc/xdg/reflector/reflector.conf
sudo sed -i "s/# --country France,Germany/--country 'Canada,United States'/g" /etc/xdg/reflector/reflector.conf
sudo systemctl start reflector.service
xargs -a "$HOME"/pacman.txt sudo pacman -Syu --needed
sudo systemctl enable ly.service
sudo systemctl enable paccache.timer
sudo systemctl enable reflector.timer
arch_backup /etc/environment
arch_environment "XDG_CURRENT_DESKTOP=sway"
arch_environment "XDG_SESSION_DESKTOP=sway"
arch_environment "QT_QPA_PLATFORM=wayland"
arch_environment "QT_QPA_PLATFORMTHEME=qt6ct"
arch_environment "SDL_VIDEODRIVER=wayland"
arch_environment "_JAVA_AWT_WM_NONREPARENTING=1"
arch_environment "EDITOR=nvim"
arch_environment "VISUAL=nvim"
if [ "$(sudo virt-what)" != "" ]; then
	arch_environment "VIRTUAL_MACHINE=true"
fi
arch_backup /etc/ly/config.ini
sudo sed -i 's/#animate = false/animate = true/g' /etc/ly/config.ini
sudo sed -i 's/#animation = 0/animation = 1/g' /etc/ly/config.ini
arch_backup /etc/systemd/logind.conf
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/g' /etc/systemd/logind.conf
sudo rm -f /usr/share/qt5ct/colors/darker_green.conf
sudo cp /usr/share/qt5ct/colors/darker.conf /usr/share/qt5ct/colors/darker_green.conf
sudo sed -i 's/#ff12608a,/#ff00aa00,/g' /usr/share/qt5ct/colors/darker_green.conf
sudo rm -f /usr/share/qt6ct/colors/darker_green.conf
sudo cp /usr/share/qt6ct/colors/darker.conf /usr/share/qt6ct/colors/darker_green.conf
sudo sed -i 's/#ff12608a,/#ff00aa00,/g' /usr/share/qt6ct/colors/darker_green.conf
sudo rm -rf /usr/share/themes/Breeze-Dark-Green
sudo cp -r /usr/share/themes/Breeze-Dark /usr/share/themes/Breeze-Dark-Green
sudo sed -i 's/#3daee9/#00aa00/g' /usr/share/themes/Breeze-Dark-Green/gtk-2.0/gtkrc
sudo sed -i 's/#3daee9/#00aa00/g' /usr/share/themes/Breeze-Dark-Green/gtk-3.0/gtk.css
sudo sed -i 's/#3daee9/#00aa00/g' /usr/share/themes/Breeze-Dark-Green/gtk-4.0/gtk.css
cp /usr/share/color-schemes/BreezeDark.colors "$HOME"/.config/kdeglobals
sed -i 's/61,174,233/0,170,0/g' "$HOME"/.config/kdeglobals
magick /usr/share/backgrounds/archlinux/gritty.png -modulate 100,100,50 "$HOME"/.config/sway/gritty_green.png
mkdir -p "$HOME"/.config/chezmoi
cp "$HOME"/chezmoi.toml "$HOME"/.config/chezmoi/chezmoi.toml
if [ "$SHELL" != "/bin/zsh" ]; then
	chsh -s /bin/zsh
fi
git config --global core.editor nvim
git config --global diff.tool batdiff
git config --global difftool.prompt false
git config --global difftool.batdiff.cmd 'batdiff $LOCAL $REMOTE'
if [ ! -e "$HOME"/.ssh/id_ed25519.pub ]; then
	ssh-keygen -t ed25519
fi
mkdir -p "$HOME"/arch/aur
pushd "$HOME"/arch/aur
if [ ! -d "$HOME"/arch/aur/paru ]; then
	git clone https://aur.archlinux.org/paru.git
	pushd "$HOME"/arch/aur/paru
	makepkg -si
	popd
fi
popd
xargs -a "$HOME"/paru.txt paru -Syu --needed
nwg-look -a
mkdir -p "$HOME"/screenshots
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
		flameshot)
			paru -Syu --needed flameshot-git
			;;
		webex)
			paru -Syu --needed webex-bin
			;;
		uefi)
			sudo pacman -Syu --needed fwupd
			fwupdmgr refresh
			fwupdmgr get-updates
			fwupdmgr update
			;;
		vb)
			sudo pacman -Syu --needed virtualbox virtualbox-host-modules-arch
			;;
		vb-lts)
			sudo pacman -Syu --needed virtualbox virtualbox-host-dkms linux-lts-headers
			;;
		kvm)
			sudo pacman -Syu --needed virt-manager qemu libvirt iptables-nft dnsmasq
			sudo systemctl enable libvirtd.service
			sudo usermod -a -G libvirt "$(whoami)"
			sudo virsh net-autostart default
			;;
		docker)
			sudo pacman -Syu --needed docker docker-compose
			sudo systemctl enable docker.service
			;;
	esac
	shift
done
sudo paccache -rk1
set +x
echo "sudo reboot"
