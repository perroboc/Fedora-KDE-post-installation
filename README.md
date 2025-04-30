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

Some recommendations:

- [Vesktop](https://flathub.org/apps/dev.vencord.Vesktop): Discord alternative with good wayland integration
- [Haruna](https://flathub.org/apps/org.kde.haruna): Cool video player
- [Heroic Games Launcher](https://flathub.org/apps/com.heroicgameslauncher.hgl): Install games from GOG, Epic, and Amazon
- [JamesDSP](https://flathub.org/apps/me.timschneeberger.jdsp4linux): System wide audio equalizer!
- [OnlyOffice](https://flathub.org/apps/org.onlyoffice.desktopeditors): VERY similar to Microsoft Office, works better than OpenOffice IMHO
- [Steam](https://flathub.org/apps/com.valvesoftware.Steam): Seems to work great!
- Would recommend 1password and firefox, too, but they don't talk with each other through flatpak (yet)

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

### Set international US Keyboard

Configure the International US Keyboard by setting it to English (US, intl., with dead keys), and setup a `.XCompose` file to ignore useless letters.

```
curl -o $HOME/.XCompose https://raw.githubusercontent.com/raelgc/win_us_intl/master/.XCompose
```

### Blender on AMD hardware

```
sudo dnf install rocm-hip rocm-hip-devel
```

### CoreCtrl

Allows to set the GPU limits and fan speeds.

Install
```
sudo dnf install corectrl
```

Set to auto start
```
cp /usr/share/applications/org.corectrl.CoreCtrl.desktop ~/.config/autostart/org.corectrl.CoreCtrl.desktop
```

To autostart minimized, go to the bottom **System** tab in CoreCtrl, then select the top **CoreCtrl** tab, and click in the top right corner **Settings** button, and make sure "Start minimized on system tray" is selected.
![image](https://github.com/user-attachments/assets/cd7f501f-d15a-4e5b-99b3-24799e05c797)


Set to not ask for password
```
sudo nano /etc/polkit-1/rules.d/90-corectrl.rules
```
```
polkit.addRule(function(action, subject) {
    if ((action.id == "org.corectrl.helper.init" ||
         action.id == "org.corectrl.helperkiller.init") &&
        subject.local == true &&
        subject.active == true &&
        subject.isInGroup("your-user-group")) {
            return polkit.Result.YES;
    }
});
```
Make sure to replace your-user-group with your user group name, which should be your user name! You can check with `groups`.
```console
$ groups
perroboc wheel
```

Edit Grub
```
sudo nano /etc/default/grub
```

Add this line to it: `GRUB_CMDLINE_LINUX_DEFAULT="rhgb quiet amdgpu.ppfeaturemask=0xffffffff"`.

By default the file should look something like this:
```
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rhgb quiet"
GRUB_CMDLINE_LINUX_DEFAULT="rhgb quiet amdgpu.ppfeaturemask=0xffffffff"
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
```

Then apply it:
```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

And reboot!
