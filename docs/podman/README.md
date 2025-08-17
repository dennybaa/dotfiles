# Podman rootless

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

```shell
systemctl --user daemon-reload
systemctl --user enable podman-auto-update.timer

```