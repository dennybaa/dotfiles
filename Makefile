.PHONY: $(shell grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | cut -d: -f1)
SHELL := /bin/bash

# Default target
all: base
desktop: base packages-desktop nix-desktop

base: packages-base
	$(MAKE) nix-tools
	$(MAKE) nix-code

packages-base:
	./packages/base.sh
	$(MAKE) nix-tools

packages-desktop:
	./packages/desktop.sh

# dynamic target to install nix profiles
nix-%:
	@cd nix/$* && nix profile install .

stow:
	stow -v .

stow-systemd:
	mkdir -p ~/.config/systemd && cd stowes/.config/systemd && stow -v -t ~/.config/systemd . || :

stow-all: stow stow-systemd

stow-clean:
	cd stowes/.config/systemd && stow -D -v -t ~/.config/systemd . || :
	stow -D -v .
