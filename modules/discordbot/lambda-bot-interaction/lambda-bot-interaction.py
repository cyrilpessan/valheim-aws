import json
import boto3
import os
from nacl.signing import VerifyKey

lambda_client = boto3.client('lambda')

''' public key found on Discord Application -> General Information page '''
DISCORD_PUBLIC_KEY = os.getenv('DISCORD_PUBLIC_KEY')

PING_PONG = {"type": 1}

RESPONSE_TYPES = {
    "PONG": 1,
    "ACK_NO_SOURCE": 2,
    "MESSAGE_WITH_SOURCE": 4,
    "ACK_WITH_SOURCE": 5
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

    headers = {
        'Content-Type': 'application/json'
    }
    
    headers_full = {
        'Access-Control-Allow-Credentials': "true",
        'Access-Control-Allow-Headers': 'Authorization,Content-Type',
        'Access-Control-Allow-Methods': 'OPTIONS,POST',
        'Content-Type': 'application/json',
        "Vary": 'Origin',
    }

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

    # dummy return
    ret = {
        "type": RESPONSE_TYPES['MESSAGE_WITH_SOURCE'],
        "data": {
            "tts": False,
            "content": "BEEP BOOP",
            "embeds": [],
            "allowed_mentions": []
        }
    }
    return ret

    # if (event):
    #     t = json_extract(event, 'type')[0]
    #     if t == 1:
    #         # Return pongs for pings
    #         if (verified):
    #             return {
    #                 "type": 1
    #             }

    #     elif t == 2:
    #         # Invoke the lambda to respond to the deferred message.
    #         lambda_client.invoke(FunctionName=os.getenv('COMMAND_LAMBDA_ARN'),
    #                              InvocationType='Event',
    #                              Payload=json.dumps(event, separators=(',', ':')))

    #         # Note that all responses are deferred to meet Discord's 3 second
    #         # response time requirement.
    #         if (verified):
    #             return {
    #                 type: 5,
    #             }
    #     else:
    #         print("[UNAUTHORIZED] invalid request signature")


if __name__ == '__main__':
    ret = lambda_handler(json.loads("""
{
    "timestamp": "1672870533",
    "signature": "cc56363eb607989ebae3906a19169396c07431797a6ba1f608f146f03dc19ec0ab510d873ce149aa8062505a972cc0a50136b03e43ef102961fcb741f8f92400",
    "jsonBody": {
        "app_permissions": "1071698664017", 
        "application_id": "834767686721732668", 
        "channel_id": "834806595653337130", 
        "data": {
            "guild_id": "499707027052953601", 
            "id": "1059961525995065385", 
            "name": "blep", 
            "options": [
                {
                    "name": "animal", 
                    "type": 3, 
                    "value": "animal_dog"
                }
            ], 
            "type": 1
        }, 
        "entitlement_sku_ids": [], 
        "guild_id": "499707027052953601", 
        "guild_locale": "en-US", 
        "id": "1060320610921762816", 
        "locale": "fr", 
        "member": {
            "avatar": null, 
            "communication_disabled_until": null, 
            "deaf": false, 
            "flags": 0, 
            "is_pending": false, 
            "joined_at": "2018-10-10T22:17:19.460000+00:00", 
            "mute": false, 
            "nick": null, 
            "pending": false, 
            "permissions": "4398046511103", 
            "premium_since": null, 
            "roles": ["834835797508096030"], 
            "user": 
            {
                "avatar": "5864bea833678f890fe7020a8845d1bf", 
                "avatar_decoration": null, 
                "discriminator": "6075", 
                "id": "434705857490452480", 
                "public_flags": 128, 
                "username": "splattist"
            }
        }, 
        "token": "aW50ZXJhY3Rpb246MTA2MDMyMDYxMDkyMTc2MjgxNjpGbmo2ZGp6Q1pFT1NYY1Z2SXFpNWFJMVI5N0pERHFsU3JFcTVyMEdsWUlUVXNZMEhla2xOeDdGUko1V2hObGN4djE2ZndtY3VyUVNVY0IwclJscmZhbjJPWWM0ZXVyclVZQUVTZ245WEhrVFpvTjA3b2dTdzY1dkl5NXRnMmxKbw", 
        "type": 2, 
        "version": 1
    }
}
    """), "")
    print(ret)
