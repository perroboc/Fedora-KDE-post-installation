## 1Password

Instructions from the official [1password instructions](https://support.1password.com/install-linux/#fedora-or-red-hat-enterprise-linux)
```
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf install 1password
```

To autostart minimized, add it to the Autostart settings, and add the `--silent` argument at the end.

![image](https://github.com/user-attachments/assets/e7f292fc-b5ec-4523-a4c9-660e6d60cc8d)

## Chezmoi
Generate SSH keys to conect to private dotfiles repo
```
ssh-keygen -t rsa
cat $HOME/.ssh/id_rsa.pub
```
And add them to [GitHub](https://github.com/settings/ssh/new) to get personal dotfiles.

Install chezmoi, upgrade it, and initiate it with the private dotfiles repo:
```
sudo dnf install git
sudo rpm -i https://github.com/twpayne/chezmoi/releases/download/v2.47.1/chezmoi-2.47.1-x86_64.rpm
chezmoi upgrade
chezmoi init --apply --ssh git@github.com:perroboc/dotfiles.git
```

## Maestral
Dropbox alternative client.
```
pipx install maestral[gui]
```

Add `maestral_qt` to `$PATH`:
```shell
ln -s $(readlink -f $HOME/.local/bin/maestral)_qt $HOME/.local/bin/maestral_qt
```

### Shortcut

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

## CoreCtrl

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
