# Root Makefile for the dotfiles repo.
#
# Provisioning is handled by mise (`mise run ...`); this file holds
# repo-level maintenance chores that don't belong to a stow package.

SHELL := /bin/bash

# Repo root, so targets work regardless of the invocation directory.
ROOT := $(patsubst %/,%,$(dir $(realpath $(lastword $(MAKEFILE_LIST)))))

# Stow package holding the Yazi config.
YAZI_DIR := stow/bundle-default/.config/yazi
YAZI_PLUGINS_DIR := $(YAZI_DIR)/plugins

.DEFAULT_GOAL := help

.PHONY: help
help: ## List available targets
	@printf 'Usage:\n  make <target>\n\nTargets:\n'
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(lastword $(MAKEFILE_LIST)) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-32s\033[0m %s\n", $$1, $$2}'

##@ Yazi

.PHONY: update-yazi-plugins
update-yazi-plugins: ## Update all vendored Yazi plugins
	git -C "$(ROOT)" subtree pull \
		--prefix=$(YAZI_PLUGINS_DIR)/fd-fzf.yazi \
		https://github.com/masaki39/fd-fzf.yazi main --squash
