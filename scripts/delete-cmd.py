import os
import sys
import logging
import requests
from dotenv import load_dotenv

load_dotenv()


LOG_LEVEL = os.getenv('LOG_LEVEL', 'ERROR')
logging.basicConfig(level=LOG_LEVEL)
logger = logging.getLogger()

logger.info("""
[INFO] Script called to delete an already existing command from the 
bot and guild defined in the .env file (the user may have to create it 
following the example file .env.example).

The script must be called with one argument which is the command ID to 
be deleted.
""")

if len(sys.argv) != 2:
    logger.error("Missing parameter.")
    exit(code=-1)

DISCORD_COMMAND_ID = sys.argv[1]

DISCORD_APPLICATION_ID = os.getenv('DISCORD_APPLICATION_ID')
DISCORD_GUILD_ID = os.getenv('DISCORD_GUILD_ID')
DISCORD_BOT_TOKEN = os.getenv('DISCORD_BOT_TOKEN')

# print(f"DISCORD_APPLICATION_ID: {DISCORD_APPLICATION_ID}")
# print(f"DISCORD_GUILD_ID: {DISCORD_GUILD_ID}")
# print(f"DISCORD_BOT_TOKEN: {DISCORD_BOT_TOKEN}")
# print(f"DISCORD_COMMAND_ID: {DISCORD_COMMAND_ID}")

logger.info(
    f"Trying to remove the Discord command with ID: \"{DISCORD_COMMAND_ID}\"...")

# check inputs
if DISCORD_APPLICATION_ID is None or \
        DISCORD_GUILD_ID is None or \
        DISCORD_BOT_TOKEN is None or \
        DISCORD_COMMAND_ID is None:
    logger.error("[ERROR] Missing environment variables.")
    exit(code=-1)


url_delete = f"https://discord.com/api/v10/applications/{DISCORD_APPLICATION_ID}/guilds/{DISCORD_GUILD_ID}/commands/{DISCORD_COMMAND_ID}"
logger.debug(f"Deleting on Discord using the DELETE resource on url: {url_delete}")

# For authorization, you can use either your bot token
headers = {
    "Authorization": f"Bot {DISCORD_BOT_TOKEN}"
}

# or a client credentials token for your app with the applications.commands.update scope
# headers = {
#     "Authorization": "Bearer <my_credentials_token>"
# }

r = requests.delete(url_delete, headers=headers)
logger.info(r)
