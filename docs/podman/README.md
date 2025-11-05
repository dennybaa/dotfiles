# Podman rootless

## recommended

Run stow and create systemd user configuration:

```shell
cd ~/dotfiles

make package-base
make stow-all
```

Actually podman.service has `Delegate=true` which should delegate all available cgroup controllers.

## *optional* can be skiped (The k3d documentation shows a more granular approach)

By default, a non-root user can only get memory controller and pids controller to be delegated.

To run properly we need to enable CPU, CPUSET, and I/O delegation:

```shell
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo tee /etc/systemd/system/user@.service.d/delegate.conf <<EOF
[Service]
Delegate=cpu cpuset io memory pids
EOF
sudo systemctl daemon-reload
```
