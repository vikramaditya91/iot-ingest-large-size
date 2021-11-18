import boto3
import json


def lambda_handler(event, context):
    # Get the service client.
    s3 = boto3.client('s3')

    # Generate the URL to get 'key-name' from 'bucket-name'
    url = s3.generate_presigned_post(event['bucket_name'],
                                     event['filename'],
                                     ExpiresIn=60)
    print(f"Presigned url is {url}")

    client = boto3.client('iot-data', region_name='eu-central-1')

    # Change topic, qos and payload
    response = client.publish(
        topic=event['topic_to_post'],
        qos=1,
        payload=json.dumps(url)
    )

    return {
        'statusCode': 200,
        # 'body': url
    }

