
sudo -i true

# install flatpak packages
flatpak install -y com.brave.Browser \
    org.gimp.GIMP \
    com.getmailspring.Mailspring \
    org.telegram.desktop \
    com.slack.Slack \
    us.zoom.Zoom


if [ -z "$NOPREP" ]; then
    # prep warp
    wget -qO- https://releases.warp.dev/linux/keys/warp.asc | sudo gpg --dearmor -o /etc/apt/keyrings/warpdotdev.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/warpdotdev.list > /dev/null
    # prep megasync
    curl -fsSL https://mega.nz/keys/MEGA_signing.key | sudo gpg --dearmor -o /usr/share/keyrings/meagsync.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/meagsync.gpg] https://mega.nz/linux/repo/xUbuntu_$(lsb_release -rs 2>/dev/null)/ ./" | sudo tee /etc/apt/sources.list.d/megasync.list > /dev/null
fi

# Get apps
sudo apt update
sudo apt install -y \
    warp-terminal \
    megasync \
    syncthing-gtk \
    transmission-gtk \
    keepassxc \
    remmina
