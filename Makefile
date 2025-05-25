SHELL := bash
USER := $(shell whoami)

FLAKE_DIR ?= $(CURDIR)/home
FLAKE_ARRT ?= $(FLAKE_DIR)#${USER}

#Nixのインストール
NIX_INSTALL_SCRIPT := https://nixos.org/nix/install

NIX_FLAGS := --extra-experimental-features 'nix-command flakes'

.PHONY: all bootstrap install-nix enable-flakes switch update gc clean

all: bootstrap

bootstrap: install-nix enable-flakes switch 
	@echo "Bootstrap complete. You can now use Nix with flakes."

install-nix:
	@if ! command -v nix &> /dev/null; then \
		echo "Installing Nix..."; \
		curl -L ${NIX_INSTALL_SCRIPT} | sh; \
		echo "Nix installed. Please restart your shell."; \
	else \
		echo "Nix is already installed."; \
	fi

enable-flakes:
	@echo "Enabling Nix flakes..."
	@sudo mkdir -p /etc/nix
	@if grep -q "experimental-features.*flakes" /etc/nix/nix.conf 2>/dev/null; then \
		echo "Flakes are already enabled in /etc/nix/nix.conf."; \
	else \
		echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf; \
		echo "Flakes enabled in /etc/nix/nix.conf."; \
	fi

switch:
	@nix run ${NIX_FLAGS} github:nixcommunity/home-manager/master -- \
		-b bak switch --flake ${FLAKE_ARRT}

update:
	@nix flake update $(FLAKE_DIR)

gc:
	@nix-collect-garbage -d
	@echo "Garbage collection complete."

clean:
	@echo "Cleaning up..."
	@rm -rf result
	@echo "Cleaned up."

