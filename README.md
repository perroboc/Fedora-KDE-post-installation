# Fedora-KDE-post-installation

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


### zed + terra repo


Info at website: https://terra.fyralabs.com/
```
sudo dnf install --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' terra-release
sudo snd install zed
```


### ffmpeg + RPMFusion


```
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager --enable fedora-cisco-openh264
```


```
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686
sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf groupupdate multimedia
```


these dont seem necessary:
```
sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf update @sound-and-video
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
#### Fix for HiDPI resolution set to 2x


```
desktop-file-install --dir=$HOME/.local/share/applications --set-key=Exec --set-value="env STEAM_FORCE_DESKTOPUI_SCALING=2.0 /usr/bin/steam %U" /usr/share/applications/steam.desktop
update-desktop-database $HOME/.local/share/applications
```
## Remove Plasma 6 Bloat


```
sudo dnf group remove libreoffice
sudo dnf remove libreoffice-core elisa-player dragon kamoso kmahjongg kmines kpat kolourpaint kontact kde-connect kmail korganizer kaddressbook akregator krdc krfb mediawriter im-chooser kgpg kmouth kmousetool neochat skanpage plasma-welcome
```


## Fixes


### Can't access some websites


This can be fixed by repopulating a clean `resolv.conf` file:
```shell
sudo systemctl disable --now systemd-resolved
sudo mv /etc/resolv.conf /etc/resolv.conf.bak
sudo systemctl enable --now systemd-resolved
```


Check the output when the issue happens before using any workarounds:


```bash
resolvectl --no-pager status
resolvectl --no-pager query domain.that.works
resolvectl --no-pager query domain.that.fails
```
### AMD workaround for system freezes:


Note: Might not be required anymore after disabling OC


```shell
echo rcu_nocbs=0-$(($(nproc)-1))
sudo nano /etc/default/grub
```


Edit kernel parameters:
```
GRUB_CMDLINE_LINUX="rhgb quiet rcu_nocbs=0-31 pci=nomsi"
```


Then update grub:
```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```


### Timezone in motherboard


```
timedatectl set-local-rtc 0
timedatectl set-ntp true
```


### NTP using gateway


```
sudo nano /etc/chrony.conf
```


```conf
## These servers were defined in the installation:  
#server _gateway iburst  
  
## Use public servers from the pool.ntp.org project.  
## Please consider joining the pool (https://www.pool.ntp.org/join.html).  
server 0.fedora.pool.ntp.org iburst  
server 1.fedora.pool.ntp.org iburst  
server 2.fedora.pool.ntp.org iburst  
server 3.fedora.pool.ntp.org iburst
```


```
systemctl restart chronyd
```


### Disable hibernation


These should be set up in `systemd` by masking (disabling) the targets. In effect, the targets change from `Loaded: loaded (/usr/lib/systemd/system/sleep.target; static)` to `Loaded: masked (Reason: Unit sleep.target is masked.)`


- Disable: `sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target`
- Check: `sudo systemctl status sleep.target suspend.target hibernate.target hybrid-sleep.target`
- Enable: `sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target` 


### HDR on gamescope


From https://copr.fedorainfracloud.org/coprs/vulongm/gamescope-git/


```shell
sudo dnf copr enable vulongm/gamescope-git
sudo dnf update --refresh
sudo dnf install gamescope
```


can be disabled by


```shell
sudo dnf copr disable vulongm/gamescope-git
sudo dnf distro-sync
```


then in games:


```
gamescope --hdr-enabled --nested-width 3840 --nested-height 2160 --output-width 3840  --output-height 2160 --fullscreen  %command%
```


### KDE Equalizer


From https://github.com/Audio4Linux/JDSP4Linux
```shell
sudo dnf copr enable arrobbins/JDSP4Linux
sudo dnf update --refresh
sudo dnf install JamesDSP
```


or really just install it from flatpak! works OK, too


### Disable Mitigations


`sudo grubby --update-kernel=ALL --args="mitigations=off"`
