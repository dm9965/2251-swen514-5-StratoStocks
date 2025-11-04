def handler(event, context):
    # super tiny example handler — returns a short message and the event
    body = "Hey! This is the Stratostocks lambda." 
    return {
        "statusCode": 200,
        "body": body,
        "event": event or {}
    }
