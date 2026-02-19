#!/bin/bash
set -euo pipefail

# Check if rpm-ostree packages are already installed
if rpm -q 1password &>/dev/null && rpm -q fcitx5 &>/dev/null && ! rpm -q firefox &>/dev/null; then
  PHASE=2
else
  PHASE=1
fi

if [ "$PHASE" -eq 1 ]; then
  echo "=== Phase 1: pre-reboot ==="

  echo "--- 1Password repo ---"
  cat << EOF | sudo tee /etc/yum.repos.d/1password.repo
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF

  echo "--- rpm-ostree: remove Firefox, layer 1Password + fcitx5 ---"
#  rpm-ostree override remove firefox firefox-langpacks
  rpm-ostree install \
    1password \
    fcitx5 \
    fcitx5-autostart \
    fcitx5-configtool \
    fcitx5-gtk \
    fcitx5-qt

  echo "--- Hardware clock ---"
  sudo timedatectl set-local-rtc '0'
  sudo timedatectl set-ntp true

  echo ""
  echo "=== Phase 1 complete. Reboot and run this script again. ==="
  exit 0
fi

echo "=== Phase 2: post-reboot ==="

echo "--- Flatpak remotes ---"
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
sudo flatpak remote-modify --no-filter --enable flathub 2>/dev/null || true
sudo flatpak remote-delete --force fedora 2>/dev/null || true
sudo flatpak remote-delete --force fedora-testing 2>/dev/null || true

echo "--- Flatpak apps ---"
flatpak install -y flathub org.mozilla.firefox
flatpak install -y flathub org.gtk.Gtk3theme.Breeze org.gtk.Gtk3theme.Breeze-Dark

echo "--- GTK dark theming override ---"
sudo flatpak override --system \
  --filesystem=xdg-config/gtk-3.0:ro \
  --filesystem=xdg-config/gtkrc-2.0:ro \
  --filesystem=xdg-config/gtk-4.0:ro \
  --filesystem=xdg-config/gtkrc:ro

echo "--- Firefox user.js ---"
FLATPAK_FF_DIR="$HOME/.var/app/org.mozilla.firefox/config/mozilla/firefox"

if [ ! -d "$FLATPAK_FF_DIR" ]; then
  echo "    Creating Firefox profile (first launch)..."
  flatpak run org.mozilla.firefox --headless &>/dev/null &
  FF_PID=$!
  for i in $(seq 1 30); do
    if [ -d "$FLATPAK_FF_DIR" ] && find "$FLATPAK_FF_DIR" -maxdepth 1 -name "*.default-release" -type d 2>/dev/null | grep -q .; then
      break
    fi
    sleep 1
  done
  kill "$FF_PID" 2>/dev/null || true
  wait "$FF_PID" 2>/dev/null || true
fi

FF_PROFILE=$(find "$FLATPAK_FF_DIR" -maxdepth 1 -name "*.default-release" -type d | head -1)

if [ -z "$FF_PROFILE" ]; then
  echo "ERROR: Could not find Firefox profile in $FLATPAK_FF_DIR" >&2
  exit 1
fi

cat > "$FF_PROFILE/user.js" << 'EOF'
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("media.webspeech.synth.enabled", false);
EOF
echo "    user.js written to $FF_PROFILE"

echo "--- fcitx5 configuration ---"
# Set fcitx5 as KDE's virtual keyboard (KWin manages the lifecycle)
kwriteconfig6 --file kwinrc --group Wayland --key InputMethod /usr/share/applications/org.fcitx.Fcitx5.desktop

# Set system keyboard layout to US International (matches fcitx5 profile)
kwriteconfig6 --file kxkbrc --group Layout --key Use true
kwriteconfig6 --file kxkbrc --group Layout --key LayoutList us
kwriteconfig6 --file kxkbrc --group Layout --key VariantList intl

# Environment for XWayland apps
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/fcitx5.conf << 'EOF'
XMODIFIERS=@im=fcitx
GTK_IM_MODULE=
QT_IM_MODULE=
EOF

# .XCompose for US International keyboard (Windows-style dead keys)
curl -o ~/.XCompose https://raw.githubusercontent.com/raelgc/win_us_intl/master/.XCompose

# fcitx5 input method profile
mkdir -p ~/.config/fcitx5
cat > ~/.config/fcitx5/profile << 'EOF'
[Groups/0]
Name=Default
Default Layout=us-intl
DefaultIM=keyboard-us-intl

[Groups/0/Items/0]
Name=keyboard-us-intl
Layout=

[GroupOrder]
0=Default
EOF

echo "--- chezmoi ---"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

echo "--- SSH key ---"
if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "your-email@example.com"
  echo ""
  echo "Public key (add this to your Git server):"
  cat ~/.ssh/id_ed25519.pub
fi

echo "--- pipx + Maestral ---"
python3 -m ensurepip --upgrade
python3 -m pip install --user pipx
pipx install "maestral[gui]"
ln -sf "$(readlink -f "$HOME/.local/bin/maestral")_qt" "$HOME/.local/bin/maestral_qt"

mkdir --parents "$HOME/.local/share/icons"
cp "$HOME/.local/share/pipx/venvs/maestral/share/icons/hicolor/512x512/apps/maestral.png" \
   "$HOME/.local/share/icons/maestral.png"

mkdir --parents "$HOME/.local/share/applications"
desktop-file-install --dir="$HOME/.local/share/applications" \
  "$HOME/.local/share/pipx/venvs/maestral/share/applications/maestral.desktop"
update-desktop-database ~/.local/share/applications

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Remaining manual steps:"
echo "  1. Reboot (or log out/in) for fcitx5 to start via KWin"
echo "  2. Add your SSH public key to your Git server, then run:"
echo "       chezmoi init git@your-server.com:your-user/dotfiles.git"
echo "       chezmoi diff"
echo "       chezmoi apply"
