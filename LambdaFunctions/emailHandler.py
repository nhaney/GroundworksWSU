import json
import boto3
from botocore.exceptions import ClientError
from addReportToDB import reportToDB
from updateUserInDB import updateReporterUser
from incrementReportCount import getRID

AWS_REGION = "us-west-2"

def reportHandler(event, context):
    '''
    This is the handler called by the
    AWS lambda function when a report is submitted
    It calls the following functions:
    reportToDB() - adds the report to the DB
    updateReporterUser() - updates the user in the DB who made report
    sendEmail() - sends an email to operator to notify report has been made
    '''
	#error check the request form
    if not 'location' in event or not 'time' in event or not 'photo' in event or not 'description' in event or not 'ranking' in event or not 'user' in event:
    	return "Invalid Request!"
    #now that we know we have a valid request, get reportID from server
    newRID = getRID()
    #from the report handler we need to both update DB and send notification email
    finalResponse = "Report " + str(newRID) + ": "
    finalResponse += reportToDB(event["location"], event['time'], event['photo'], event['description'], event['ranking'], event['user'], newRID)
    finalResponse += updateReporterUser(event['user'], event['time'], newRID)
    finalResponse += sendEmail(event, context, newRID)
    return finalResponse


def sendEmail(event, context, rid):
    '''
    This function sends an email based on
    report submitted. It uses AWS SES to do so
    '''

    # Create a new SES resource and specify a region.
    client = boto3.client('ses',region_name=AWS_REGION)

    #sender address
    SENDER = "nigel.haney@wsu.edu"

    #receiver address
    RECIPIENT = "nigel.haney@wsu.edu"

    #CONFIGURATION_SET = "ConfigSet"

    

    #body_text
    BODY_TEXT = ("Amazon SES Test (Python)\r\n"
                 "This email was sent with Amazon SES using the "
                 "AWS SDK for Python (Boto)."
                )

    #charset for the email
    CHARSET = "UTF-8"

    returnResponse = ""
    if 'subject' in event:
    	SUBJECT = event['subject']  + " ReportID: " + str(rid)
    else:
    	SUBJECT = "test email with SES and Lambda" + " ReportID: " + str(rid)
    if 'html' in event:
    	BODY_HTML = event['html']
    else:
    	BODY_HTML = """<html>
		<head></head>
		<body>
		  <h1>Amazon SES Test (SDK for Python)</h1>
		  <p>This email was sent with
		    <a href='https://aws.amazon.com/ses/'>Amazon SES</a> using the
		    <a href='https://aws.amazon.com/sdk-for-python/'>
		      AWS SDK for Python (Boto)</a>.</p>
            <br><br>

		</body>
		</html>
            """ 

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
