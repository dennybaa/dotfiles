# Podman rootless

## recommended

Though podman.service has `Delegate=true` which should delegate all available cgroup controllers.

## *Optional* delegate.conf

Can be skipped (Delegate=yes) is usually already set. However k3d documentation suggests a more extended configuration. By default, a non-root user can only get memory controller and PIDs controller to be delegated.

To run properly we need to enable CPU, CPUSET, and I/O delegation:

```shell
sudo mkdir -p /etc/systemd/system/user@.service.d
sudo tee /etc/systemd/system/user@.service.d/delegate.conf <<EOF
[Service]
Delegate=cpu cpuset io memory pids
EOF
sudo systemctl daemon-reload
```

## K3D

To create a k3d cluster in Podman specify the feature gate:

```shell
k3d cluster create test --k3s-arg '--kubelet-arg=feature-gates=KubeletInUserNamespace=true@server:*'
```
