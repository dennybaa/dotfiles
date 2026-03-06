# Nix

## Fix nix-upgrade (error: public key is not valid)

The upgrade-nix command is failing because it's trying to verify the signature of the new Nix 2.31.3 download using a key it currently thinks is invalid. Force it by disabling signature verification for the upgrade only:
bash

```shell
sudo -i nix --option require-sigs false upgrade-nix
```
