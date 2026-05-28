#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="dinotty"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/dinotty"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}[INFO]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC} $*"; }

[[ "$(id -u)" -eq 0 ]] || { echo -e "${RED}请使用 sudo 运行${NC}"; exit 1; }

echo "即将卸载 Dinotty..."
echo ""

# 停止并禁用服务
if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
    systemctl stop "$SERVICE_NAME"
    info "服务已停止"
fi

if systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null; then
    systemctl disable "$SERVICE_NAME" 2>/dev/null
    info "已取消开机自启"
fi

# 删除服务文件
if [[ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]]; then
    rm "/etc/systemd/system/${SERVICE_NAME}.service"
    systemctl daemon-reload
    info "systemd 服务文件已删除"
fi

# 删除二进制
if [[ -f "${INSTALL_DIR}/dinotty-server" ]]; then
    rm "${INSTALL_DIR}/dinotty-server"
    info "二进制文件已删除"
fi

# 询问是否删除配置
echo ""
if [[ -t 0 ]]; then
    read -rp "是否删除配置目录 (${CONFIG_DIR})？[y/N] " confirm
else
    confirm=""
fi
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DIR"
    ok "配置目录已删除"
else
    info "保留了配置目录: ${CONFIG_DIR}"
fi

ok "Dinotty 已完全卸载"
