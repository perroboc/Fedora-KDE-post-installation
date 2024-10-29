# Fedora-KDE-post-installation

Updated for Fedora 41

## General recommendations

Configure the International US Keyboard by setting it to English (US, intl., with dead keys), and setup a `.XCompose` file to ignore useless letters.

```
curl -o $HOME/.XCompose https://raw.githubusercontent.com/raelgc/win_us_intl/master/.XCompose
```

## RPMFusion + ffmpeg

Install RPMFusion
```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf upgrade --refresh -y
sudo dnf update @core
```

Change to full ffmpeg

```
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
```

### Hardware codecs
AMD:
```
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
```

Nvidia:
```
sudo dnf install akmod-nvidia
sudo dnf install libva-nvidia-driver
```

Intel:
```
sudo dnf install intel-media-driver
```

### Firmware
Enable repo
```
sudo dnf install rpmfusion-nonfree-release-tainted
sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware"
```

Update firmware
```
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
```

## Remove Plasma 6 Bloat

```
sudo dnf group remove libreoffice
sudo dnf remove libreoffice-core elisa-player dragon kamoso kmahjongg kmines kpat kolourpaint kontact kde-connect kmail korganizer kaddressbook akregator krdc krfb mediawriter im-chooser kgpg kmouth kmousetool neochat skanpage plasma-welcome kdebugsettings krdp
```

## Firefox settings

### `about:config`:

- fix delay when middle clicking
  - `accessibility.force_disabled`: `1`
- disable pocket
  - `extensions.pocket.enabled`: `false`
- fix emojis
  - `font.name-list.emoji`: `Noto Color Emoji`
- Better KDE Plasma integration
  - `media.hardwaremediakeys.enabled`: `false`
- disable speech synthesis
  - `media.webspeech.synth.enabled`: `false`
- use native KDE file dialog
  - `widget.use-xdg-desktop-portal.file-picker`: `1`

### Plasma addon
Make sure you have the [Plasma addon](https://addons.mozilla.org/en-US/firefox/addon/plasma-integration/) installed


## Personal preferences

These are personal preferences and how I install them. Might be useful for someone else

### 1Password

Instructions from the official [1password instructions](https://support.1password.com/install-linux/#fedora-or-red-hat-enterprise-linux)
```
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf install 1password
```

### Chezmoi
Generate SSH keys to conect to private dotfiles repo
```
ssh-keygen -t rsa
```
And add them to [GitHub](https://github.com/settings/ssh/new) to get personal dotfiles.

Install chezmoi, upgrade it, and initiate it with the private dotfiles repo:
```
sudo dnf install git
sudo rpm -i https://github.com/twpayne/chezmoi/releases/download/v2.47.1/chezmoi-2.47.1-x86_64.rpm
chezmoi upgrade
chezmoi init --apply --ssh git@github.com:perroboc/dotfiles.git
```

### Maestral
Dropbox alternative client.
```
pipx install maestral[gui]
```

Add `maestral_qt` to `$PATH`:
```shell
ln -s $(readlink -f $HOME/.local/bin/maestral)_qt $HOME/.local/bin/maestral_qt
```

#### Shortcut

Set `.desktop` shortcut file and icon

Create the Icon:
```
mkdir --parents $HOME/.local/share/icons
cp $HOME/.local/share/pipx/venvs/maestral/share/icons/hicolor/512x512/apps/maestral.png $HOME/.local/share/icons/maestral.png
```

Create the Shortcut:
```
mkdir --parents $HOME/.local/share/applications
desktop-file-install --dir=$HOME/.local/share/applications $HOME/.local/share/pipx/venvs/maestral/share/applications/maestral.desktop
update-desktop-database ~/.local/share/applications
```

Upgrade if required:
```
pipx upgrade maestral
```

## Flatpak recommendations:

- Vesktop (Discord alternative with good wayland integration)
- Haruna (Cool video player)
- Heroic Games Launcher (Install games from GOG, Epic, and Amazon)
- JamesDSP (Equalizer!)
- OnlyOffice (VERY similar to Microsoft Office, and works great)
- Steam (seems to work OK!)
- Would recommend 1password and firefox, too, but they don't talk with each other through flatpak (yet)
