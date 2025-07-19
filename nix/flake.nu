use std/log

# Render flake.nix
export def generate [
    --bundle: string                    # bundle of packages defined in bundles.nu
    --release (-r): string              # release of nixos (eg: 25.05 or latest)
] {
    source ./bundles.nu
    let release =  match $release {
            $it if ([latest unstable] | any {|e| $e == $it}) => "unstable" ,
            _ => $"release-($release | default $defaultRelease)"
        }

    let dependencies = $bundles | get $bundle
      | reduce -f '' {|pkg, acc|
            $acc + ("" | fill --width 10) + $"($pkg) = pkgs.($pkg);\n" # each item with padding
        }
      | str trim -r -c "\n"
    

    let flake = $'
    {
      # Can use nixos-unstable instead of the specific release
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/($release)";
      outputs = { self, nixpkgs }: {
        packages.x86_64-linux = let
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in {
($dependencies)
        };
      };
    }
    '

    return ($flake | sed -e 's/^    //' -e '1d' -e '$d')
}
