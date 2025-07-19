use ./flake.nu

# Nix profile install software packages
#
# The script reads flake.nu template and updates flake.nix after this 
# performs nix profile install .#vscode for each of packages from the given bundle
def main [
    --bundle: string = desktop          # bundle of packages defined in bundles.nu
    --release (-r): string              # release of nixos (eg: 25.05 or latest)
] {
    flake generate --bundle=$bundle --release=$release
}
