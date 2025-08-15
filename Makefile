.PHONY: all local dots remove-all

# Default target
all: dots local

local:
	stow -v local

dots:
	stow -v .

remove-all:
	stow -D . local
