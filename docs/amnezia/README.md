# Amnezia

It requires the systemd service to be setup and enabled, it has certain mitigation to work on ubuntu 24.04 which can useful:

```shell
cd ~/dotfiles && cat docs/amnezia/amneziavpn.service | sed "s/<REPLACE-USER>/$USER/" | sudo tee /etc/systemd/system/amneziavpn.service
sudo systemctl daemon-reload && systemctl enable amneziavpn
```

Note: this service loads the script `.local/scripts/amneziavpn-service-wrapper`, copy or link it using stow:

```shell
cd ~/dotfiles
make
```


Now you use should be able to use the amnezia client (which in turn mitigates some run issues):
```shell
~/.local/scripts/amneziavpn-wrapper
```

PS: the desktop file is also available if you stowed (~/.local/share/applications/AmneziaVPN.desktop)
