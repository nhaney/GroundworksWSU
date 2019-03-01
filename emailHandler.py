import json
import boto3
from botocore.exceptions import ClientError

#sender address
SENDER = "nigel.haney@wsu.edu"

#receiver address
RECIPIENT = "nigel.haney@wsu.edu"

#CONFIGURATION_SET = "ConfigSet"

AWS_REGION = "us-west-2"

#subject line for email
SUBJECT = "test email with SES and Lambda"

#body_text
BODY_TEXT = ("Amazon SES Test (Python)\r\n"
             "This email was sent with Amazon SES using the "
             "AWS SDK for Python (Boto)."
            )
#customizable body HTML
BODY_HTML = """<html>
<head></head>
<body>
  <h1>Amazon SES Test (SDK for Python)</h1>
  <p>This email was sent with
    <a href='https://aws.amazon.com/ses/'>Amazon SES</a> using the
    <a href='https://aws.amazon.com/sdk-for-python/'>
      AWS SDK for Python (Boto)</a>.</p>
</body>
</html>
            """ 

#charset for the email
CHARSET = "UTF-8"

# Create a new SES resource and specify a region.
client = boto3.client('ses',region_name=AWS_REGION)



def sendEmail(event, context):
    returnResponse = ""
    SUBJECT = event['subject']
    BODY_HTML = event['html']
    #send email
    try:
        #Provide the contents of the email.
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
        )
    # Display an error if something goes wrong. 
    except ClientError as e:
        returnResponse += e.response['Error']['Message']
    else:
        returnResponse += "Email sent! Message ID:"
        returnResponse += response['MessageId']

    return returnResponse
