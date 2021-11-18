import boto3
from botocore.exceptions import ClientError

# Replace sender@example.com with your "From" address.
# This address must be verified with Amazon SES.
SENDER = "vikramaditya91spam@gmail.com"

# Replace recipient@example.com with a "To" address. If your account
# is still in the sandbox, this address must be verified.
RECIPIENT = "vikramaditya91@gmail.com"

# Specify a configuration set. If you do not want to use a configuration
# set, comment the following variable, and the
# ConfigurationSetName=CONFIGURATION_SET argument below.
# CONFIGURATION_SET = "ConfigSet"

# If necessary, replace us-west-2 with the AWS Region you're using for Amazon SES.
AWS_REGION = "eu-central-1"

# The subject line for the email.
SUBJECT = "Motion Detected"


# The character encoding for the email.
CHARSET = "UTF-8"


def lambda_handler(event, context):
    # Get the service client.
    # Create a new SES resource and specify a region.
    client = boto3.client('ses', region_name=AWS_REGION)
    records = event['Records'][0]
    image_url = f"https://s3-{records['awsRegion']}.amazonaws.com/{records['s3']['bucket']['name']}/{records['s3']['object']['key']}"
    # The email body for recipients with non-HTML email clients.
    BODY_TEXT = f"Dudu was caught moving around\r\n{event}\r\n{image_url}"

    # The HTML body of the email.
    BODY_HTML = f"""<html>
    <head></head>
    <body>
      <h1>Dudu Caught</h1>
      <p>This email was sent {image_url}
        <a href='{event}'>{event} SES</a> using the
        <a href='{event}'>
          AWS SDK for Python (<a href='{image_url}'>{image_url})</a>.</p>
    </body>
    </html>
                """

    # Try to send the email.
    try:
        # Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
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

