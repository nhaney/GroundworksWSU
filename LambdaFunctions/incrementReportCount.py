from __future__ import print_function # Python 2/3 compatibility
import boto3
from botocore.exceptions import ClientError
import json
import decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('ridCounter')

def getRID():
    '''
    This function will get current
    highest reportID and return it to 
    the user. It will also increment this
    value so that the next time this
    function is called, it will return
    the next reportID
    '''
    try:
        response = table.get_item(
            Key={
                'counterName':'master'
            })
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        item = response['Item']
        print(item)
        print()
        #we need to update the global rid count here, after 
        print(updateRID())
        return int(item['ridCount'])

def updateRID():
    '''
    This function increments reportID counter
    to be one higher
    '''
    response = table.update_item(
        Key={'counterName': 'master'},
        UpdateExpression="set ridCount = ridCount + :val",
        ExpressionAttributeValues={
            ':val': decimal.Decimal(1)
        },
        ReturnValues="UPDATED_NEW"
    )

    return "Updated Global ReportID count."
