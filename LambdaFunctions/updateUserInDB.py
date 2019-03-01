from __future__ import print_function # Python 2/3 compatibility
import boto3
from botocore.exceptions import ClientError
import json
import decimal

def updateReporterUser(uname, time, rid):
    '''
    This function is used to update the user 
    who made a report in the table.

    updated fields:
    ridList
    lastReport
    totalReports

    These do not have much use at the moment for my app,
    but will be useful when expanding
    '''
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('Users')
    print("Attempting to update " + uname + "...")
    try:
        response = table.get_item(Key={
            'username': uname,
            'usertype': 'reporter'
            })
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        item = response['Item']
        #here are the updates
        item['ridList'] += " " + str(rid)
        item['lastReport'] = time
        item['totalReports'] += 1
        #end of updates
        putResponse = table.put_item(Item=item)
        print("Sucessfully updated user based on report.")
    return "Updated user account based on report."



