import os, sys
import logging
import requests
import json
from dotenv import load_dotenv

load_dotenv()

# log level shall be one of the following:
# 'CRITICAL', 'FATAL', 'ERROR', 'WARN', 'WARNING', 'INFO': INFO, 'DEBUG': DEBUG, 'NOTSET': NOTSET,

LOG_LEVEL = os.getenv('LOG_LEVEL', 'ERROR')

logging.basicConfig(level=LOG_LEVEL)
logger = logging.getLogger()

logger.info("""
Script called to create a new command in the 
bot and guild defined in the .env file (the user may have to create it 
following the example file .env.example).

The script must be called with one argument pointing on a json file describing
the command to create.
""")

if len(sys.argv) != 2:
    logger.error("Missing parameter.")
    exit(code=-1)

# get json file path
json_path = sys.argv[1]

# Opening JSON file
f = open(json_path)

# returns JSON object as a dictionary
discord_cmd_json = json.load(f)
logger.debug(discord_cmd_json)

# retreive env variables
DISCORD_APPLICATION_ID = os.getenv('DISCORD_APPLICATION_ID')
DISCORD_GUILD_ID = os.getenv('DISCORD_GUILD_ID')
DISCORD_BOT_TOKEN = os.getenv('DISCORD_BOT_TOKEN')

# check inputs
if DISCORD_APPLICATION_ID is None or \
        DISCORD_GUILD_ID is None or \
        DISCORD_BOT_TOKEN is None:
    logger.error("[ERROR] Missing environment variables.")
    exit(code=-1)

logger.debug("DISCORD_APPLICATION_ID: " + DISCORD_APPLICATION_ID)
logger.debug("DISCORD_GUILD_ID: " + DISCORD_GUILD_ID)
logger.debug("DISCORD_BOT_TOKEN: " + DISCORD_BOT_TOKEN)

url = f"https://discord.com/api/v10/applications/{DISCORD_APPLICATION_ID}/guilds/{DISCORD_GUILD_ID}/commands"
logger.debug(f"Registering on Discord using the POST resource on url: {url}")

# For authorization, you can use either your bot token
headers = {
    "Authorization": f"Bot {DISCORD_BOT_TOKEN}"
}

# or a client credentials token for your app with the applications.commands.update scope
# headers = {
#     "Authorization": "Bearer <my_credentials_token>"
# }

r = requests.post(url, headers=headers, json=discord_cmd_json)
logger.info(r)
