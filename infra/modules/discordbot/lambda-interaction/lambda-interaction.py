import json
import boto3
import os
from nacl.signing import VerifyKey

sns_client = boto3.client('sns')


''' public key found on Discord Application -> General Information page '''
DISCORD_PUBLIC_KEY = os.getenv('DISCORD_PUBLIC_KEY')

PING_PONG = {"type": 1}

RESPONSE_TYPES = {
    "PONG": 1,
    "CHANNEL_MESSAGE_WITH_SOURCE": 4,
    "DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE": 5,
    "DEFERRED_UPDATE_MESSAGE": 6,
    "UPDATE_MESSAGE": 7,
    "APPLICATION_COMMAND_AUTOCOMPLETE_RESULT": 8,
    "MODAL": 9,
}

def verifyEvent(event) -> bool:
    '''Verifies that an event coming from Discord is legitimate. 
    @param {any} event The event to verify from Discord.
    @return {Exception} Raise an Exception if the 
    verification fails..
    '''
    signature = event['signature']
    timestamp = event['timestamp']
    body = event['jsonBody']
    
    message = timestamp.encode() + json.dumps(body, separators=(",", ":")).encode()
    verify_key = VerifyKey(bytes.fromhex(DISCORD_PUBLIC_KEY))
    verify_key.verify(message, bytes.fromhex(signature)) # raises an error if unequal


def lambda_handler(event, context):
    '''Handles incoming events from the Discord bot.
    @param {IDiscordEventRequest} event The incoming request to handle.
    @param {Context} _context The context this request was called with.
    @return Returns a response to send back to Discord (json-typed).
    '''
    # print(discordSecrets)
    # print(f"Received event: {json.dumps(event, indent=4)}")

    # headers = {
    #     'Content-Type': 'application/json'
    # }
    
    # headers_full = {
    #     'Access-Control-Allow-Credentials': "true",
    #     'Access-Control-Allow-Headers': 'Authorization,Content-Type',
    #     'Access-Control-Allow-Methods': 'OPTIONS,POST',
    #     'Content-Type': 'application/json',
    #     "Vary": 'Origin',
    # }

    # verify the signature
    try:
        verifyEvent(event)
    except Exception as e:
        raise Exception(f"[UNAUTHORIZED] Invalid request signature: {e}")

    # extract body from the event
    body = event['jsonBody']
    
    # check if message is a ping
    if body.get("type") == 1:
        return PING_PONG
    
    # TODO check the other types
    
    cmd_name = body.get("data").get("name")
    # cmd_options = body.get("data").get("options")
    
    response = sns_client.publish(
        TargetArn=os.environ['SNS_PUBLISH_VH_ARN'],
        Message=json.dumps({
            "default": json.dumps(event)
            }),
        MessageStructure='json',
        MessageAttributes= {
            "command": { 
                'DataType': 'String', 
                'StringValue': cmd_name 
                } 
            }
    )

    # ACK the initial command, the "command" lambda will takeover the real answer.
    ret = {
        "type": RESPONSE_TYPES['DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE'],
        "data": {
            "tts": False,
            "content": "Processing the request. Please wait...",
            "embeds": [],
            "allowed_mentions": []
        }
    }
    return ret

###############################################################################
## TEST
if __name__ == '__main__':
    pass