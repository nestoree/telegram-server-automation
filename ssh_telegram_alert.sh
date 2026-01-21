#!/bin/bash

BOT_TOKEN=""
CHAT_ID=""

send_telegram() {
    local MESSAGE="$1"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${MESSAGE}" \
        -d parse_mode="Markdown" > /dev/null
}

journalctl -u ssh -f | while read -r line; do

    if echo "$line" | grep -q "Accepted"; then
        USER=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if ($i=="for") print $(i+1)}')
        IP=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if ($i=="from") print $(i+1)}')
        COUNT=$(who | wc -l)

        send_telegram "✅ *Login SSH exitoso*
👤 Usuario: \`$USER\`
🌍 IP: \`$IP\`
👥 Conectados ahora: *$COUNT*"
    fi

    if echo "$line" | grep -q "Failed password"; then
        USER=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if ($i=="for") print $(i+1)}')
        IP=$(echo "$line" | awk '{for(i=1;i<=NF;i++) if ($i=="from") print $(i+1)}')
        COUNT=$(who | wc -l)

        send_telegram "⚠️ *Intento SSH fallido*
👤 Usuario: \`$USER\`
🌍 IP: \`$IP\`
👥 Conectados ahora: *$COUNT*"
    fi

don