# Fixes

The following is completely optional, but have saved me from time to time...

## amdgpu driver crashes under heavy load

It seems that the amdgpu driver sets the top freq of the GPU to what the GPU reports, and this is not always accurate? So the fix is to limit the freq to what's published by the vendor.

1. Search your GPU vendors website info, or in [techpowerup.com](https://www.techpowerup.com). For example, my card is a [Asus TUF RX 7900 XTX OC](https://www.techpowerup.com/gpu-specs/asus-tuf-rx-7900-xtx-gaming-oc.b9931)
2. Get the Boost Clock speed (in my case, 2565 MHz)
3. Install CoreCtrl (instructions in the main markdown file), and set the maximum frequency to this value ![image](https://github.com/user-attachments/assets/fa31a96a-1dc6-482d-8ac4-4162125471f1)

## Can't access some websites

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

## AMD workaround for system freezes:

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

## Timezone in motherboard

```
timedatectl set-local-rtc 0
timedatectl set-ntp true
```

## NTP using gateway

```
sudo nano /etc/chrony.conf
```

```conf
# These servers were defined in the installation:
#server _gateway iburst

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
server 0.fedora.pool.ntp.org iburst
server 1.fedora.pool.ntp.org iburst
server 2.fedora.pool.ntp.org iburst
server 3.fedora.pool.ntp.org iburst
```

```
systemctl restart chronyd
```

## Disable hibernation

These should be set up in `systemd` by masking (disabling) the targets. In effect, the targets change from `Loaded: loaded (/usr/lib/systemd/system/sleep.target; static)` to `Loaded: masked (Reason: Unit sleep.target is masked.)`

- Disable: `sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target`
- Check: `sudo systemctl status sleep.target suspend.target hibernate.target hybrid-sleep.target`
- Enable: `sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target`

## HDR on gamescope

Requires latest gamescope, which can be installed from https://copr.fedorainfracloud.org/coprs/vulongm/gamescope-git/

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

## Disable Mitigations

`sudo grubby --update-kernel=ALL --args="mitigations=off"`
