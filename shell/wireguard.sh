#!/bin/bash

set -e

# ========== CONFIG ==========
WG_INTERFACE="wg0"
WG_PORT=51820
WG_SERVER_CIDR="10.0.0.0/24"
WG_SERVER_IP="10.0.0.1"
WG_CONF_DIR="/etc/wireguard"
WG_CONF="$WG_CONF_DIR/$WG_INTERFACE.conf"
CLIENT_DIR="$HOME/wg-clients"
USE_UFW=false

# ========== FUNCTIONS ==========

print_usage() {
  echo "Usage: $0 [--install] [--ufw] [--add-client <name>] [--qr <name>] [--help]"
  echo ""
  echo "  --install           Install and configure WireGuard server"
  echo "  --ufw               Enable UFW firewall and allow WireGuard port"
  echo "  --add-client NAME   Add a new client with specified NAME"
  echo "  --qr NAME           Show QR code for client NAME"
  echo "  --help              Show this help message"
  exit 0
}

install_wireguard() {
  echo "[+] Installing WireGuard..."
  apt update && apt install -y wireguard qrencode curl

  mkdir -p "$WG_CONF_DIR" "$CLIENT_DIR"
  chmod 700 "$WG_CONF_DIR"

  echo "[+] Generating server keys..."
  SERVER_PRIV=$(wg genkey)
  SERVER_PUB=$(echo "$SERVER_PRIV" | wg pubkey)

  echo "[+] Writing server config..."
  cat > "$WG_CONF" <<EOF
[Interface]
Address = $WG_SERVER_IP/24
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIV
SaveConfig = true
PostUp = iptables -t nat -A POSTROUTING -s $WG_SERVER_CIDR -o eth0 -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -s $WG_SERVER_CIDR -o eth0 -j MASQUERADE
EOF

  echo "[+] Enabling IP forwarding..."
  sysctl -w net.ipv4.ip_forward=1
  grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf || echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

  if [ "$USE_UFW" = true ]; then
    echo "[+] Configuring UFW..."
    apt install -y ufw
    ufw allow "$WG_PORT"/udp
    ufw enable
  fi

  echo "[+] Starting WireGuard..."
  systemctl enable wg-quick@$WG_INTERFACE
  systemctl start wg-quick@$WG_INTERFACE

  echo "[✓] WireGuard server setup complete."
}

get_next_ip() {
  last_ip=$(grep AllowedIPs "$WG_CONF" | awk '{print $3}' | cut -d'/' -f1 | sort -t. -k4 -n | tail -n1)
  if [[ -z "$last_ip" ]]; then
    echo "10.0.0.2"
  else
    IFS='.' read -r o1 o2 o3 o4 <<< "$last_ip"
    next_ip="10.0.0.$((o4+1))"
    echo "$next_ip"
  fi
}

add_client() {
  CLIENT_NAME="$1"
  [[ -z "$CLIENT_NAME" ]] && echo "❌ Client name required for --add-client" && exit 1

  CLIENT_PRIV=$(wg genkey)
  CLIENT_PUB=$(echo "$CLIENT_PRIV" | wg pubkey)
  CLIENT_IP=$(get_next_ip)
  SERVER_PUB=$(grep PrivateKey "$WG_CONF" | awk '{print $3}' | xargs -I{} sh -c "echo {} | wg pubkey")
  SERVER_ENDPOINT=$(curl -s ifconfig.me):$WG_PORT

  CLIENT_CONF="$CLIENT_DIR/$CLIENT_NAME.conf"

  echo "[+] Creating client config: $CLIENT_CONF"
  cat > "$CLIENT_CONF" <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV
Address = $CLIENT_IP/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

  chmod 600 "$CLIENT_CONF"

  echo "[+] Adding client to server config..."
  cat >> "$WG_CONF" <<EOF

# $CLIENT_NAME
[Peer]
PublicKey = $CLIENT_PUB
AllowedIPs = $CLIENT_IP/32
EOF

  systemctl restart wg-quick@$WG_INTERFACE
  echo "[✓] Client '$CLIENT_NAME' added with IP $CLIENT_IP"
}

show_qr() {
  CLIENT_NAME="$1"
  CONF="$CLIENT_DIR/$CLIENT_NAME.conf"
  [[ ! -f "$CONF" ]] && echo "❌ Client config not found: $CONF" && exit 1

  echo "[+] QR Code for $CLIENT_NAME:"
  cat "$CONF" | qrencode -t ansiutf8
}

# ========== ARG PARSING ==========

if [[ "$#" -eq 0 ]]; then
  print_usage
fi

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --install) DO_INSTALL=true ;;
    --ufw) USE_UFW=true ;;
    --add-client) DO_ADD=true; CLIENT_NAME="$2"; shift ;;
    --qr) DO_QR=true; QR_NAME="$2"; shift ;;
    --help) print_usage ;;
    *) echo "Unknown option: $1"; print_usage ;;
  esac
  shift
done

# ========== EXECUTION ==========

[ "$DO_INSTALL" = true ] && install_wireguard
[ "$DO_ADD" = true ] && add_client "$CLIENT_NAME"
[ "$DO_QR" = true ] && show_qr "$QR_NAME"
