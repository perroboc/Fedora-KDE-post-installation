# Other useful tips

Not fixes. Not installed by default unless needed... This is what OTHER.md means.

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
