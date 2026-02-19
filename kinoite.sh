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
    fcitx5-configtool \
    fcitx5-gtk \
    fcitx5-qt

  echo "--- Hardware clock ---"
  sudo timedatectl set-local-rtc '0'
  sudo timedatectl set-ntp true

  echo "--- .XCompose ---"
  curl -o ~/.XCompose https://raw.githubusercontent.com/raelgc/win_us_intl/master/.XCompose

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
  # Wait for the profile directory to appear
  for i in $(seq 1 30); do
    if find "$FLATPAK_FF_DIR" -name "*.default-release" -type d 2>/dev/null | grep -q .; then
      break
    fi
    sleep 1
  done
  kill "$FF_PID" 2>/dev/null || true
  wait "$FF_PID" 2>/dev/null || true
fi

PROFILE=$(find "$FLATPAK_FF_DIR" -maxdepth 1 -name "*.default-release" -type d | head -1)

if [ -z "$PROFILE" ]; then
  echo "ERROR: Could not find Firefox profile in $FLATPAK_FF_DIR" >&2
  exit 1
fi

cat > "$PROFILE/user.js" << 'EOF'
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("media.webspeech.synth.enabled", false);
EOF
echo "    user.js written to $PROFILE"

echo "--- 1Password + Flatpak Firefox integration ---"
# Allow Firefox to talk to the host's Flatpak portal
flatpak override --user --talk-name=org.freedesktop.Flatpak org.mozilla.firefox

# Create the wrapper script that bridges into the host
mkdir -p ~/.var/app/org.mozilla.firefox/data/bin
cat << 'EOF' > ~/.var/app/org.mozilla.firefox/data/bin/1password-wrapper.sh
#!/bin/bash
flatpak-spawn --host /opt/1Password/1Password-BrowserSupport "$@"
EOF
chmod +x ~/.var/app/org.mozilla.firefox/data/bin/1password-wrapper.sh

# Native messaging manifest so Firefox knows about the extension bridge
mkdir -p ~/.var/app/org.mozilla.firefox/.mozilla/native-messaging-hosts
cat << EOF > ~/.var/app/org.mozilla.firefox/.mozilla/native-messaging-hosts/com.1password.1password.json
{
  "name": "com.1password.1password",
  "description": "1Password BrowserSupport",
  "path": "$HOME/.var/app/org.mozilla.firefox/data/bin/1password-wrapper.sh",
  "type": "stdio",
  "allowed_extensions": [
    "{0a75d802-9aed-41e7-8daa-24c067386e82}",
    "{25fc87fa-4d31-4fee-b5c1-c32a7844c063}",
    "{d634138d-c276-4fc8-924b-40a0ea21d284}"
  ]
}
EOF

# Whitelist flatpak-session-helper so 1Password accepts the sandboxed connection
sudo mkdir -p /etc/1password
echo "flatpak-session-helper" | sudo tee /etc/1password/custom_allowed_browsers > /dev/null

echo "    1Password bridge configured"

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
echo "Remaining manual step:"
echo "  Add your SSH public key to your Git server, then run:"
echo "    chezmoi init git@your-server.com:your-user/dotfiles.git"
echo "    chezmoi diff"
echo "    chezmoi apply"
