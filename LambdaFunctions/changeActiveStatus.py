from __future__ import print_function # Python 2/3 compatibility
import boto3
from botocore.exceptions import ClientError
import json


def reportStatusHandler(event, context):
    '''
    This function is the handler
    that gets called by the AWS lambda
    function when a report status is changed

    Usage:
    >>> reportStatusHandler({"status":"ignored", "reportID":"8"}, "")
    Sucessfully updated report.
    'Successfully updated ReportID 8 to have status ignored.'
    '''
    try:
        if event['status'] == "active" or event['status'] == "ignored" or event['status'] == "completed" or event['status'] == "in progress":
            toggleStatus(event['reportID'], event['status'])
            return "Successfully updated ReportID " + event['reportID'] + " to have status " + event['status'] + "."
        else:
            return "Invalid status."
    except:
        return "ReportID not found."

def toggleStatus(reportID, status):
    '''
    This function toggles the status
    of a report to whatever the operator
    selects
    '''
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('Reports')
    try:
        response = table.get_item(Key={
            'reportID': int(reportID)
            })
    except ClientError as e:
        return e.response['Error']['Message']
    item = response['Item']
    #here are the updates
    item['currentStatus'] = status
    #end of updates
    putResponse = table.put_item(Item=item)
    print("Sucessfully updated report.")


if __name__ == '__main__':
    import doctest
    doctest.testmod()
