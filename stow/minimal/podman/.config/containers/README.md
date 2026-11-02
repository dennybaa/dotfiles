# Docker auth (podman)

## auth.json

[docker-credential-helpers](https://github.com/docker/docker-credential-helpers) installs plugin for Freedesktop Secret Service API which
allows to creds in a desktop's keyring/wallet (such as GNOME Keyring).

### store credentials

* run

    ```shell
    docker-credential-secretservice store
    ```

* input and CTRL+D

    ```yaml
    {"ServerURL":"docker.io","Username":"YOUR_USERNAME","Secret":"YOUR_SECRET"}
    ```
