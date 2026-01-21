#!/usr/bin/env python3
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes
import subprocess

# CONFIGURACIÓN
BOT_TOKEN = ""
CHAT_ID = ""  # tu chat personal
CORE_SCRIPT = "/usr/local/bin/update_wg_ip.sh"

async def update_ip_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    try:
        result = subprocess.run([CORE_SCRIPT], capture_output=True, text=True)
        # Tomar stdout y stderr
        output = result.stdout.strip()
        error_output = result.stderr.strip()

        # Construir mensaje, asegurando que nunca quede vacío
        if not output and not error_output:
            message = "⚠️ Script ejecutado, pero no hubo salida."
        else:
            message = ""
            if output:
                message += output
            if error_output:
                message += f"\n❌ Errores:\n{error_output}"

        await context.bot.send_message(
            chat_id=update.effective_chat.id,
            text=message,
            parse_mode="Markdown"
        )
    except Exception as e:
        await context.bot.send_message(
            chat_id=update.effective_chat.id,
            text=f"❌ Error ejecutando el bot: {e}"
        )

if __name__ == "__main__":
    app = ApplicationBuilder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("update_ip", update_ip_command))
    print("Bot ejecutándose...")
    app.run_polling()