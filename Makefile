SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# 変数定義
USER := $(shell whoami)
HOME_DIR := $(HOME)
DOTFILES_DIR := $(shell pwd)
NIX_CONFIG_DIR := $(HOME)/.config/nix

# Nixのフラグ
NIX_FLAGS := --extra-experimental-features 'nix-command flakes'

# デフォルトターゲット
.PHONY: all
all: setup

# ヘルプメッセージ
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  setup     - 初回セットアップ（flakes有効化 + Home Manager適用）"
	@echo "  switch    - Home Manager設定を適用"
	@echo "  update    - flakeをアップデート"
	@echo "  build     - 設定をビルド（適用はしない）"
	@echo "  check     - flakeの構文チェック"
	@echo "  gc        - ガベージコレクション実行"
	@echo "  clean     - 一時ファイルをクリーンアップ"
	@echo "  status    - 現在の状態を表示"
	@echo "  help      - このヘルプを表示"

# 初回セットアップ
.PHONY: setup
setup: enable-flakes switch
	@echo "✅ セットアップが完了しました！"
	@echo "📝 新しいシェルセッションで環境変数を読み込むため、以下を実行してください："
	@echo "   source ~/.nix-profile/etc/profile.d/nix.sh"

# Nix flakesを有効化
.PHONY: enable-flakes
enable-flakes:
	@echo "🔧 Nix flaksを有効化しています..."
	@mkdir -p $(NIX_CONFIG_DIR)
	@if ! grep -q "experimental-features.*flakes" $(NIX_CONFIG_DIR)/nix.conf 2>/dev/null; then \
		echo "experimental-features = nix-command flakes" >> $(NIX_CONFIG_DIR)/nix.conf; \
		echo "✅ flakesを有効化しました"; \
	else \
		echo "✅ flakesは既に有効化されています"; \
	fi

# Home Manager設定を適用
.PHONY: switch
switch:
	@echo "🏠 Home Manager設定を適用しています..."
	@nix run $(NIX_FLAGS) home-manager/master -- switch --flake .#$(USER)
	@echo "✅ Home Manager設定が適用されました"

# 設定をビルドのみ（適用はしない）
.PHONY: build
build:
	@echo "🔨 設定をビルドしています..."
	@nix build $(NIX_FLAGS) .#homeConfigurations.$(USER).activationPackage
	@echo "✅ ビルドが完了しました（result/にあります）"

# flakeをアップデート
.PHONY: update
update:
	@echo "📦 flakeをアップデートしています..."
	@nix flake update
	@echo "✅ アップデートが完了しました"

# flakeの構文チェック
.PHONY: check
check:
	@echo "🔍 flakeの構文をチェックしています..."
	@nix flake check
	@echo "✅ 構文チェックが完了しました"

# ガベージコレクション
.PHONY: gc
gc:
	@echo "🗑️  ガベージコレクションを実行しています..."
	@nix-collect-garbage -d
	@echo "✅ ガベージコレクションが完了しました"

# 一時ファイルのクリーンアップ
.PHONY: clean
clean:
	@echo "🧹 一時ファイルをクリーンアップしています..."
	@rm -rf result result-*
	@echo "✅ クリーンアップが完了しました"

# 現在の状態を表示
.PHONY: status
status:
	@echo "📊 現在の状態:"
	@echo "  User: $(USER)"
	@echo "  Dotfiles Dir: $(DOTFILES_DIR)"
	@echo "  Nix Config Dir: $(NIX_CONFIG_DIR)"
	@echo ""
	@echo "🔧 Nix情報:"
	@nix --version 2>/dev/null || echo "  Nixがインストールされていません"
	@echo ""
	@echo "📦 インストール予定パッケージ:"
	@grep -A 20 "home.packages" home.nix | grep "pkgs\." | sed 's/.*pkgs\./  - /' | sed 's/;$$//'
	@echo ""
	@echo "⚙️  Git設定:"
	@echo "  Name: $(shell grep 'userName.*=' home.nix | cut -d'"' -f2)"
	@echo "  Email: $(shell grep 'userEmail.*=' home.nix | cut -d'"' -f2)"

# 高度なオプション：特定のパッケージのみビルド
.PHONY: build-package
build-package:
	@if [ -z "$(PACKAGE)" ]; then \
		echo "❌ PACKAGE変数を指定してください。例: make build-package PACKAGE=git"; \
		exit 1; \
	fi
	@echo "🔨 $(PACKAGE)パッケージをビルドしています..."
	@nix build $(NIX_FLAGS) nixpkgs#$(PACKAGE)

# デバッグ用：設定の詳細表示
.PHONY: show-config
show-config:
	@echo "📋 Home Manager設定の詳細:"
	@nix eval $(NIX_FLAGS) .#homeConfigurations.$(USER).config.home.packages --apply builtins.length
	@echo "パッケージ数: $$(nix eval $(NIX_FLAGS) .#homeConfigurations.$(USER).config.home.packages --apply builtins.length) 個"