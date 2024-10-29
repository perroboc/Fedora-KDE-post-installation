# Fedora-KDE-post-installation

Updated for Fedora 41

## Settings

Generate SSH keys

```
ssh-keygen -t rsa
```

Configure the International US Keyboard by setting it to English (US, intl., with dead keys), and setup a `.XCompose` file to ignore useless letters.

```
curl -o $HOME/.XCompose https://raw.githubusercontent.com/raelgc/win_us_intl/master/.XCompose
```

Optionally add them to [GitHub](https://github.com/settings/ssh/new)

## Applications

### 1Password

```
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf install 1password
```

### Chezmoi

```
sudo dnf install git
sudo rpm -i https://github.com/twpayne/chezmoi/releases/download/v2.47.1/chezmoi-2.47.1-x86_64.rpm
chezmoi upgrade
chezmoi init --apply --ssh git@github.com:perroboc/dotfiles.git
```

This should install:

- `git`
- `pipx`
- `fzf`
- `ripgrep`

### Maestral

Dropbox alternative client

```
pipx install maestral[gui]
```

Add `maestral_qt` to `$PATH`

```shell
ln -s $(readlink -f $HOME/.local/bin/maestral)_qt $HOME/.local/bin/maestral_qt
```

#### Shortcut

Set `.desktop` shortcut file and icon

##### Icon

```
mkdir --parents $HOME/.local/share/icons
cp $HOME/.local/share/pipx/venvs/maestral/share/icons/hicolor/512x512/apps/maestral.png $HOME/.local/share/icons/maestral.png
```

##### Shortcut

```
mkdir --parents $HOME/.local/share/applications
desktop-file-install --dir=$HOME/.local/share/applications $HOME/.local/share/pipx/venvs/maestral/share/applications/maestral.desktop
update-desktop-database ~/.local/share/applications
```

#### Upgrade

```
pipx upgrade maestral
```

### ffmpeg + RPMFusion

```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf upgrade --refresh -y
sudo dnf update @core
```

Change to full ffmpeg

```
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
```

I use AMD, so:

```
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
```

Firmware:

```
sudo dnf install rpmfusion-nonfree-release-tainted
sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware"
```

```
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
```

### Firefox

`about:config` requires these:

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

### Steam

```
sudo dnf install steam
```

#### Fix for HiDPI resolution set to 1.75x

```
desktop-file-install --dir=$HOME/.local/share/applications --set-key=Exec --set-value="env STEAM_FORCE_DESKTOPUI_SCALING=1.75 /usr/bin/steam %U" /usr/share/applications/steam.desktop
update-desktop-database $HOME/.local/share/applications
```

## Remove Plasma 6 Bloat

```
sudo dnf group remove libreoffice
sudo dnf remove libreoffice-core elisa-player dragon kamoso kmahjongg kmines kpat kolourpaint kontact kde-connect kmail korganizer kaddressbook akregator krdc krfb mediawriter im-chooser kgpg kmouth kmousetool neochat skanpage plasma-welcome kdebugsettings krdp
```

## Flatpak

- Vesktop (Discord alternative with good wayland integration)
- Haruna (Cool video player)
- Heroic Games Launcher (Install games from GOG, Epic, and Amazon)
- JamesDSP (Equalizer!)
- OnlyOffice (VERY similar to Microsoft Office, and works great)
- Would recommend 1password and firefox, too, but they don't talk with each other through flatpak (yet)
