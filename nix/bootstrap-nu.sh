#!/usr/bin/env bash

release=latest
if [[ "$1" =~ [0-9]+\.[0-9]+ ]]; then
    echo "processing release"
    release="nixpkgs/release-$1"
elif [[ "$1" == "latest" ]] || [[ "$release" == "latest" ]]; then
    release=nixpkgs
fi

# echo bootstrap nu
nix profile install "${release}#nushell"
