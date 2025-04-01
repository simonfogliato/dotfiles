# dotfiles
dotfiles, managed by https://www.chezmoi.io/

## Install
```bash
sudo pacman -Syu --needed chezmoi
cd ~
chezmoi init --apply simonfogliato
./arch.sh
# ./arch.sh [options]
# ./arch.sh mouse ssh print flameshot webex uefi vb vb-lts kvm docker photorec exiftool android github
sudo reboot
```

## Develop
```bash
chezmoi cd
git remote set-url origin git@github.com:simonfogliato/dotfiles.git
```
