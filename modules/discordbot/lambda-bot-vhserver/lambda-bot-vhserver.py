from dataclasses import dataclass
import json
from typing import Optional
import requests
import os

## TO BE REMOVED
import time

# DISCORD_PUBLIC_KEY = os.getenv('DISCORD_PUBLIC_KEY')
DISCORD_AUTH_TOKEN = os.getenv('DISCORD_AUTH_TOKEN')
DISCORD_APP_ID = os.getenv('DISCORD_APP_ID')

CURRENT_API_VERSION = "10"

RESPONSE_TYPES = {
    "PONG": 1,
    "CHANNEL_MESSAGE_WITH_SOURCE": 4,
    "DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE": 5,
    "DEFERRED_UPDATE_MESSAGE": 6,
    "UPDATE_MESSAGE": 7,
    "APPLICATION_COMMAND_AUTOCOMPLETE_RESULT": 8,
    "MODAL": 9,
}

@dataclass
class IDiscordRole:
    """A server role assigned to a user."""
    id: str
    name: str
    color: int
    hoist: bool
    mentionable: bool

@dataclass
class IDiscordUser:
    """The user information for a Discord member."""
    id: int
    username: str
    discriminator: str

@dataclass
class IDiscordMember:
    """A Discord member and their properties."""
    deaf: bool
    roles: list[str]
    user: IDiscordUser

@dataclass
class IDiscordRequestDataOption:
    """The name and value for a given command option if available."""
    name: str
    value: str

@dataclass
class IDiscordEndpointInfo:
    """The information for the endpoint to use when sending a response.

    Default version for the API version is 8 when not specified.
    """
    apiVersion: Optional[str]
    authToken: str
    applicationId: str

@dataclass
class IDiscordRequestData:
    """The data in the Discord request. Should be handled for actually parsing commands."""
    id: str
    name: str
    options: Optional[list[IDiscordRequestDataOption]]

@dataclass
class IDiscordJsonBody:
    """The actual Discord request data."""
    id: Optional[str]
    token: Optional[str]
    data: Optional[IDiscordRequestData]
    member: Optional[IDiscordMember]
    type: int
    version: int

@dataclass
class IDiscordEventRequest:
    """The incoming request, created via API Gateway request templates."""
    timestamp: str
    signature: str
    jsonBody: IDiscordJsonBody

@dataclass
class IDiscordResponseData:
    """The actual response data that will be used in the resulting Discord message."""
    tts: bool
    content: str
    embeds: list[any]
    allowedMentions: list[str]

def sendFollowupMessage(endpointInfo: IDiscordEndpointInfo,
                        interactionToken: str, responseData: IDiscordResponseData) -> bool:
    """Send a followup message to Discord's APIs on behalf of the bot.

    @param endpointInfo The information to use when talking to the endpoint.
    @param interactionToken The token representing the interaction to follow up on.
    @param responseData The response data to be sent to the Discord server.
    @returns Returns true if the response was succesfully sent, false otherwise.
    """
    headers = {
        'Authorization': f"Bot ${endpointInfo.authToken}",
    }
    data = {
        "allowedMentions": responseData.allowedMentions,
        "tts": responseData.tts,
        "content": responseData.content,
        "embeds": responseData.embeds,
    }

    apiVersion = endpointInfo.apiVersion if endpointInfo.apiVersion is not None else CURRENT_API_VERSION

    try:
        url = f"https://discord.com/api/v{apiVersion}/webhooks/{endpointInfo.applicationId}/{interactionToken}"
        # print(url)
        r = requests.post(url, headers=headers, json=data)
        # print(r)
        return r.status_code == 200
    except requests.exceptions.RequestException as e:
        print(f"There was an error posting a response: ${e}")
        return False

def lambda_handler(event, context):
    """lambda_handler(event, context)
    """
    print(f"Received event: ${json.dumps(event, indent=2)}")

    endpointInfo = IDiscordEndpointInfo (
        authToken = DISCORD_AUTH_TOKEN,
        applicationId = DISCORD_APP_ID,
        apiVersion = CURRENT_API_VERSION
    )

    response = IDiscordResponseData(
        tts = False,
        content = "Hello world!",
        embeds = [],
        allowedMentions = [],
    )

    response2 = IDiscordResponseData(
        tts = False,
        content = "Hello world2!",
        embeds = [],
        allowedMentions = [],
    )
    
    # message = json.loads(event['Records'][0]['Sns']['Message'])
    m = event['Records'][0]['Sns']['Message']
    message = json.loads(m)
    #print(type(message))
    #print(message)
    
    ## TO BE REMOVED: simulate delay in precessing
    time.sleep(2)

    #if (message['jsonBody', 'token'] is not None and
    if (message.get('jsonBody').get('token') is not None and
            sendFollowupMessage(
                endpointInfo,
                #message['jsonBody', 'token'],
                message.get('jsonBody').get('token'),
                response)):
        print('Responded successfully!')
        # return 0
    else:
        print('Failed to send response!')
    # return '200'
    # return -1
    
    ## TO BE REMOVED: simulate delay in precessing
    time.sleep(2)

    #if (message['jsonBody', 'token'] is not None and
    if (message.get('jsonBody').get('token') is not None and
            sendFollowupMessage(
                endpointInfo,
                #message['jsonBody', 'token'],
                message.get('jsonBody').get('token'),
                response2)):
        print('Responded successfully!')
        return 0
    else:
        print('Failed to send response!')
    # return '200'
    return -1

###############################################################################
## TEST
if __name__ == '__main__':
    ret = lambda_handler(json.loads("""
{
    "Records": [{
        "Sns": {
            "Message": {
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
        }
    }]
    
}
    """), "")
    print(ret)