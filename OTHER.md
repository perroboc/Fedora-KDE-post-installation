# Other useful tips

Not fixes. Not installed by default unless needed... This is what OTHER.md means.

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
