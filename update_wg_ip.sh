#!/bin/bash

# --- CONFIGURA ESTO ---
BOT_TOKEN=""
CHAT_ID=""
SETUPVARS="/etc/pivpn/wireguard/setupVars.conf"
CLIENT_CONF="/home/user/configs/user.conf" # Cambia esto dependiendo de donde tengas el archivo
WG_INTERFACE="wg0"
# ----------------------

send_telegram() {
    local MESSAGE="$1"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="$MESSAGE" \
        -d parse_mode="Markdown" > /dev/null
}

# Obtener IP pública actual
PUBLIC_IP=$(curl -s https://api.ipify.org)

UPDATED_FILES=()

# --- Actualizar pivpnHOST en setupVars.conf ---
CURRENT_IP_SETUP=$(grep '^pivpnHOST=' "$SETUPVARS" | cut -d'=' -f2)
if [ "$CURRENT_IP_SETUP" != "$PUBLIC_IP" ]; then
    sudo sed -i "s/^pivpnHOST=.*/pivpnHOST=$PUBLIC_IP/" "$SETUPVARS"
    UPDATED_FILES+=("$SETUPVARS")
fi

# --- Actualizar Endpoint en cliente WireGuard ---
CURRENT_ENDPOINT=$(grep '^Endpoint' "$CLIENT_CONF" | awk '{print $3}' | cut -d':' -f1)
if [ "$CURRENT_ENDPOINT" != "$PUBLIC_IP" ]; then
    sudo sed -i "s/^Endpoint = .*/Endpoint = $PUBLIC_IP:51820/" "$CLIENT_CONF"
    UPDATED_FILES+=("$CLIENT_CONF")
fi

# --- Reiniciar WireGuard si hubo cambios ---
if [ ${#UPDATED_FILES[@]} -gt 0 ]; then
    sudo systemctl restart wg-quick@$WG_INTERFACE
    MESSAGE="🌐 IP Pública actualizada: \`$PUBLIC_IP\`\n✅ Archivos actualizados:\n$(printf "%s\n" "${UPDATED_FILES[@]}")\n🔄 WireGuard reiniciado."
else
    MESSAGE="🌐 IP Pública: \`$PUBLIC_IP\` (sin cambios)"
fi

send_telegram "$MESSAGE"