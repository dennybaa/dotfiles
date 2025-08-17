.PHONY: all local dots systemd remove-systemd remove-all

# Default target
all: dots local

local:
	stow -v local

systemd:
	stow -v systemd

remove-systemd:
	stow -D systemd

dots:
	stow -v .

remove-all:
	stow -D . local systemd
