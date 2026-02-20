.PHONY: $(shell grep -E '^[a-zA-Z_-]+:' $(MAKEFILE_LIST) | cut -d: -f1)
SHELL := /bin/bash

# Default target
all:

stow:
	stow -v .

stow-systemd:
	mkdir -p ~/.config/systemd && cd stowes/.config/systemd && stow -v -t ~/.config/systemd . || :

stow-all: stow stow-systemd

stow-clean:
	cd stowes/.config/systemd && stow -D -v -t ~/.config/systemd . || :
	stow -D -v .
