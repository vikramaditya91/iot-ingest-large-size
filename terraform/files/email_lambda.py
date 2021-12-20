import boto3
import os
from botocore.exceptions import ClientError

SENDER = os.environ['FROM_ADDRESS']

RECIPIENT = os.environ['TO_ADDRESSES'].split(",")

AWS_REGION = os.environ['AWS_REGION']

SUBJECT = "Motion Detected"

CHARSET = "UTF-8"


def lambda_handler(event, context):
    # Get the service client.
    # Create a new SES resource and specify a region.
    client = boto3.client('ses', region_name=AWS_REGION)
    records = event['Records'][0]
    image_url = f"https://s3-{records['awsRegion']}.amazonaws.com/{records['s3']['bucket']['name']}/{records['s3']['object']['key']}"

    body_text = f"Motion was caught \r\n{event}\r\n{image_url}"

    # The HTML body of the email.
    body_html = f"""<html>
    <head></head>
    <body>
      <h1>Motion Caught</h1>
      <p>This email was sent with this media content: {image_url} .</p>
    </body>
    </html>
                """

    # Try to send the email.
    try:
        # Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': RECIPIENT,
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': body_html,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': body_text,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER,
            # If you are not using a configuration set, comment or delete the
            # following line
            # ConfigurationSetName=CONFIGURATION_SET,
        )
    # Display an error if something goes wrong.
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['MessageId'])

