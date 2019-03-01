import boto3
from botocore.exceptions import ClientError
import json
import decimal
#event handler when getReports GET request comes in.
#this will take an optional argument of a username
#if the username is selected, it only returns reports by that user,
#if not it returns all reports
#could further extend to have a date range argument as well
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if abs(o) % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

def getReportsHandler(event, context):
    '''
    This function will handler a get request
    for either all reports, or only a report with
    a specific reportID
    '''
    if event['reportID'] != "":
        return getReports(reportID=event['reportID'])
    else:
        return getReports()

def getReportsByUserHandler(event, context):
    '''
    This handler will be used for when we need
    to get reports by username
    '''
    if event['username'] != "":
        return getReports(username=event["username"])
    else:
        return getReports()

def getReports(username=None, reportID=None):
    '''
    This function is what supplies the json to the handler
    based on the type of report
    '''
    dynamodb = boto3.resource('dynamodb')
    reportTable = dynamodb.Table('Reports')
    ridList = []

    if username != None:
        #we get specific user list of reports
        userTable = dynamodb.Table('Users')
        try:
            response = userTable.get_item(Key={
                'username': username,
                'usertype': "reporter"
                })
        except ClientError as e:
            return e.response['Error']['Message']
        else:
            #creates a list of int from ridList
            try:
                ridList = list(map(int,response['Item']['ridList'].split()))
            except:
                return "User " + username + " does not exist!"
        print(ridList)
        #now that we have ridList, we need to return json of reports that match it
        returnJson = None
        for rid in ridList:
            try:
                response = reportTable.get_item(Key={
                    'reportID': rid
                    })
            except ClientError as e:
                print(e.response['Error']['Message'])
            else:
                if returnJson == None:
                    returnJson = response
                    returnJson['Item'] = [returnJson['Item']]
                else:
                    tempItems = response['Item']
                    returnJson['Item'].extend([tempItems])
    elif reportID != None:
        reportID = int(reportID)
        try:
            response = reportTable.get_item(Key={
                'reportID': reportID
                })
        except ClientError as e:
            print(e.response['Error']['Message'])
        try:
            returnJson = response['Item']
        except:
            return "ReportID " + str(reportID) + " does not exist!"
    else:
        response = reportTable.scan()
        #data = response['Items']
        #while 'LastEvaluatedKey' in response:
        #    response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        #    data.extend(response['Items'])
        returnJson = response

    return json.dumps(returnJson, cls=DecimalEncoder)

print(getReportsHandler({'reportID': 89}, ""))
