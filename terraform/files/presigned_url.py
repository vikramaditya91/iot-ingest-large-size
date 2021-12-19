import boto3
import json
import os

AWS_REGION = os.environ['AWS_REGION']


def lambda_handler(event, context):
    # Get the service client.
    s3 = boto3.client('s3')

    url = s3.generate_presigned_post(event['bucket_name'],
                                     event['filename'],
                                     # Assumes that the video is uploaded within 60 seconds
                                     ExpiresIn=60)
    print(f"Presigned url is {url}")

    client = boto3.client('iot-data', region_name=AWS_REGION)

    client.publish(
        topic=event['topic_to_post'],
        qos=1,
        payload=json.dumps(url)
    )

    return {
        'statusCode': 200,
    }

