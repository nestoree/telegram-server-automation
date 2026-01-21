# Telegram Server Automation

Conjunto de scripts para **automatizar tareas de servidor Linux** y **recibir alertas en Telegram**.  
Pensado especialmente para servidores domésticos, Raspberry Pi, VPS y entornos con **WireGuard / PiVPN**.

---

## 🚀 Características

- 🤖 Bot de Telegram para ejecutar comandos del sistema
- 🌐 Actualización automática de IP pública para WireGuard / PiVPN
- 🔐 Monitor en tiempo real de accesos SSH (exitosos y fallidos)
- 📩 Notificaciones instantáneas por Telegram
- 🐧 Compatible con sistemas Linux con `systemd`

---

## 🤖 1. Bot de Telegram (Python)

**Archivo:** `telegram_command_bot.py`

Bot de Telegram basado en `python-telegram-bot` que permite ejecutar scripts del sistema mediante comandos.

### Funcionalidad
- Escucha el comando `/update_ip`
- Ejecuta el script `update_wg_ip.sh`
- Devuelve la salida y errores por Telegram

### Requisitos
```bash
pip install python-telegram-bot --upgrade
```
### Configura en el archivo
```
  BOT_TOKEN = "TU_TOKEN"
  CORE_SCRIPT = "/ruta/al/update_wg_ip.sh"
```

---

## 🌐 2. Actualización automática de IP (WireGuard / PiVPN)

Archivo: **update_wg_ip.sh**

Script en Bash para entornos con IP dinámica.

### Qué hace
  - Detecta tu IP pública actual
  - Actualiza pivpnHOST en PiVPN
  - Actualiza el Endpoint de un cliente WireGuard
  - Reinicia WireGuard solo si hay cambios
  - Envía el resultado por Telegram
  - Archivos que modifica
    ```
    /etc/pivpn/wireguard/setupVars.conf
    Archivo .conf de cliente WireGuard
    ```

### Requisitos
```
  curl
  sudo
  systemctl
```

Configura en el script:
```
BOT_TOKEN=""
CHAT_ID=""
SETUPVARS="/etc/pivpn/wireguard/setupVars.conf"
CLIENT_CONF="/ruta/cliente.conf"
WG_INTERFACE="wg0"
```

## 🔐 3. Monitor de accesos SSH

Archivo: **ssh_login_monitor.sh**

Monitor en tiempo real de los logs del servicio SSH usando journalctl.

### Qué detecta
```
✅ Logins SSH exitosos
⚠️ Intentos de acceso fallidos
👤 Usuario
🌍 IP de origen
👥 Número de usuarios conectados
```

### Cómo funciona

Escucha **continuamente** los logs de ssh
Envía alertas **inmediatas** por Telegram

### Configura en el script:
```
BOT_TOKEN=""
CHAT_ID=""
```
