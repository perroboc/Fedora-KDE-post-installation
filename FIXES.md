# Fixes

The following is completely optional, but have saved me from time to time...

## amdgpu driver crashes under heavy load

It seems that the amdgpu driver sets the top freq of the GPU to what the GPU reports, and this is not always accurate? So the fix is to limit the freq to what's published by the vendor. ([relevant bug](https://gitlab.freedesktop.org/drm/amd/-/issues/3131))

I got crashes that looked like this in `journalctl`: `fedora kernel: amdgpu 0000:03:00.0: [drm] *ERROR* dc_dmub_srv_log_diagnostic_data: DMCUB error - collecting diagnostic data`

1. Search your GPU vendors website info, or in [techpowerup.com](https://www.techpowerup.com). For example, my card is a [Asus TUF RX 7900 XTX OC](https://www.techpowerup.com/gpu-specs/asus-tuf-rx-7900-xtx-gaming-oc.b9931)
2. Get the Boost Clock speed (in my case, 2565 MHz)
3. Install CoreCtrl (instructions in the main markdown file), and set the maximum frequency to this value ![image](https://github.com/user-attachments/assets/fa31a96a-1dc6-482d-8ac4-4162125471f1)

## can't pair my bluetooth device

I got good experiences installing `bluez-tools` and `bluez-deprecated` and then pairing through commandline.

Bluedevil (KDE's interface with bluetooth) might be not doing the right thing ([relevant bug](https://bugs.kde.org/show_bug.cgi?id=495615)). Try pairing through commandline:

1. `sudo systemctl restart bluetooth`
2. `bluetoothctl` to start a bluetooth control prompt
3. In the new prompt: `scan on`
4. Copy the MAC address of the device to pair (example: `[bluetooth]# [NEW] Device 88:C9:XXXXXX WH-1000XM5`)
5. `connect <MAC>` and it should pair
6. `quit` from the bluetoothctl prompt

Upon reconnection, KDE might ask for permission to connect. Make sure to click to remember this decision.

## Can't access some websites

DNS name resolution might be acting funny. This can be fixed by repopulating a clean `resolv.conf` file:

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

## Timezone in motherboard

When checking NTP, I get something like this:

```console
$ timedatectl status
               Local time: Thu 2024-10-31 11:46:52 -03
           Universal time: Thu 2024-10-31 14:46:52 UTC
                 RTC time: Thu 2024-10-31 11:46:52
                Time zone: America/Santiago (-03, -0300)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: yes

Warning: The system is configured to read the RTC time in the local time zone.
         This mode cannot be fully supported. It will create various problems
         with time zone changes and daylight saving time adjustments. The RTC
         time is never updated, it relies on external facilities to maintain it.
         If at all possible, use RTC in UTC by calling
         'timedatectl set-local-rtc 0'.
```

So I do this:
```
timedatectl set-local-rtc 0
timedatectl set-ntp true
```

And it sets the UEFI time in UTC:
```
$ timedatectl status
               Local time: Thu 2024-10-31 11:48:45 -03
           Universal time: Thu 2024-10-31 14:48:45 UTC
                 RTC time: Thu 2024-10-31 14:48:46
                Time zone: America/Santiago (-03, -0300)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no
```

BUT when dualbooting, make sure to set windows to use UTC time, too. Further instructions in the [Arch Wiki](https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows)

This requires 
## Disable hibernation

These should be set up in `systemd` by masking (disabling) the targets. In effect, the targets change from `Loaded: loaded (/usr/lib/systemd/system/sleep.target; static)` to `Loaded: masked (Reason: Unit sleep.target is masked.)`

- Disable: `sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target`
- Check: `sudo systemctl status sleep.target suspend.target hibernate.target hybrid-sleep.target`
- Enable: `sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target`

## HDR on gamescope

Requires latest gamescope, and a dnf steam installation (not a flatpak one). If you don't want to build gamescope, it can be installed from https://copr.fedorainfracloud.org/coprs/vulongm/gamescope-git/

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

then in games in steam, set it to something like:

```
gamescope --hdr-enabled --nested-width 3840 --nested-height 2160 --output-width 3840  --output-height 2160 --fullscreen  %command%
```

note: make sure to set the resolution correctly!

