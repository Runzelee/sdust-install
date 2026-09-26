#!/usr/bin/env bash
set -euo pipefail

# 公网安装脚本（由 GitHub 仓库 Runzelee/sdust-install 分发）：
# 直接从 GitHub（含加速镜像）下载，不再尝试内网源。
PRIMARY_BASE="https://hk.gh-proxy.org/https://github.com/Runzelee/sdust-install/raw/refs/heads/main"
FALLBACK_BASE="https://github.com/Runzelee/sdust-install/raw/refs/heads/main"
INSTALL_DIR="$HOME/.local/bin"
BIN_NAME="sdust"

# 检测架构
ARCH=$(uname -m)
OS=$(uname -s)

case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64)  TARGET="sdust-x86_64-unknown-linux-gnu" ;;
            *)       echo "不支持的架构: $ARCH"; exit 1 ;;
        esac
        ;;
    *)
        echo "不支持的系统: $OS（当前脚本仅支持 Linux x86_64；Windows 请使用 PowerShell 安装脚本）"
        exit 1
        ;;
esac

PRIMARY_URL="$PRIMARY_BASE/$TARGET"
FALLBACK_URL="$FALLBACK_BASE/$TARGET"

echo "系统: $OS ($ARCH)"

mkdir -p "$INSTALL_DIR"

download_success=false

if command -v curl &>/dev/null; then
    echo "尝试从镜像下载: $PRIMARY_URL"
    if curl -fSL --connect-timeout 5 "$PRIMARY_URL" -o "$INSTALL_DIR/$BIN_NAME" 2>/dev/null; then
        download_success=true
    else
        echo "镜像访问失败，尝试使用 GitHub 原链接下载: $FALLBACK_URL"
        if curl -fSL "$FALLBACK_URL" -o "$INSTALL_DIR/$BIN_NAME"; then
            download_success=true
        fi
    fi
elif command -v wget &>/dev/null; then
    echo "尝试从镜像下载: $PRIMARY_URL"
    if wget -q --timeout=5 --tries=1 "$PRIMARY_URL" -O "$INSTALL_DIR/$BIN_NAME" 2>/dev/null; then
        download_success=true
    else
        echo "镜像访问失败，尝试使用 GitHub 原链接下载: $FALLBACK_URL"
        if wget -q "$FALLBACK_URL" -O "$INSTALL_DIR/$BIN_NAME"; then
            download_success=true
        fi
    fi
else
    echo "需要 curl 或 wget，请先安装其中之一。"
    exit 1
fi

if [ "$download_success" = false ]; then
    echo "下载失败！找不到请去 sdust 仓库的 release 下载。"
    exit 1
fi

chmod +x "$INSTALL_DIR/$BIN_NAME"

# 检查 PATH
if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo "安装完成！可直接使用 sdust 命令。"
else
    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        zsh)  RC_FILE="$HOME/.zshrc" ;;
        bash) RC_FILE="$HOME/.bashrc" ;;
        *)    RC_FILE="$HOME/.profile" ;;
    esac
    LINE="export PATH=\"\$HOME/.local/bin:\$PATH\""
    if ! grep -qF '.local/bin' "$RC_FILE" 2>/dev/null; then
        echo "$LINE" >> "$RC_FILE"
        echo "已将 ~/.local/bin 添加到 $RC_FILE。"
    fi
    echo "安装完成！请运行以下命令或重启终端："
    echo "  source $RC_FILE"
fi
