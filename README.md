# Fedora-KDE-post-installation

Updated for Fedora 41

## General recommendations

Things I think everyone should do

### Remove Plasma 6 Bloat

```
sudo dnf group remove libreoffice
sudo dnf remove libreoffice-core elisa-player dragon kamoso kmahjongg kmines kpat kolourpaint kontact kmail korganizer kaddressbook akregator krdc krfb mediawriter im-chooser kgpg kmouth kmousetool neochat skanpage plasma-welcome kdebugsettings krdp
```

### Flatpak

Disable Fedora flatpak repo:
```
flatpak remote-modify fedora --disable
```

Enable Flathub:
```
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --no-filter --enable flathub
```

### Set UTC 0 time

```
sudo timedatectl set-local-rtc '0'
```

### Enable RPMFusion

Taken from [rpmfusion.org](https://rpmfusion.org/Configuration#Command_Line_Setup_using_rpm)

```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1
sudo dnf install rpmfusion-\*-appstream-data
```

To enable [full ffmpeg](https://rpmfusion.org/Howto/Multimedia):

```
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf install ffmpeg-libs libva libva-utils
```

## Personal preferences

These are personal preferences and how I install them. Might be useful for someone else

### Set international US Keyboard

Configure the International US Keyboard by setting it to English (US, intl., with dead keys), and setup a `.XCompose` file to ignore useless letters.

```
curl -o $HOME/.XCompose https://raw.githubusercontent.com/raelgc/win_us_intl/master/.XCompose
```


Some recommendations:

```
flatpak install flathub com.discordapp.Discord
flatpak install flathub com.heroicgameslauncher.hgl
flatpak install flathub me.timschneeberger.jdsp4linux
flatpak install flathub org.onlyoffice.desktopeditors
```

## Firefox settings

### `about:config`:

- fix delay when middle clicking
  - `accessibility.force_disabled`: `1`
- disable pocket
  - `extensions.pocket.enabled`: `false`
- ~fix emojis~
  - ~`font.name-list.emoji`: `Noto Color Emoji`~
- Better KDE Plasma integration
  - `media.hardwaremediakeys.enabled`: `false`
- disable speech synthesis
  - `media.webspeech.synth.enabled`: `false`
- use native KDE file dialog
  - `widget.use-xdg-desktop-portal.file-picker`: `1`

### Plasma addon

Make sure you have the [Plasma addon](https://addons.mozilla.org/en-US/firefox/addon/plasma-integration/) installed

### Blender on AMD hardware

```
sudo dnf install rocm-hip rocm-hip-devel
```
