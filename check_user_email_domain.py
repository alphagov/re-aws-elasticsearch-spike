import os

def lambda_handler(event, context):
    domain = os.getenv("DOMAIN", "@gmail.com")
    if event['request']['userAttributes']['email'].endswith(domain):
        return event
    raise Exception("Cannot authenticate user as they are not part of the correct domain.")
