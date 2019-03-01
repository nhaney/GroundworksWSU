from __future__ import print_function # Python 2/3 compatibility
import boto3
import json
import decimal

# Helper class to convert a DynamoDB item to JSON.
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if abs(o) % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

def addUser(username):
    '''
    This function will add a user to the 
    dynamodb database table for users
    Usage:
    >>> addUser("nigel.haney27@gmail.com")
    PutItem succeeded:
    '''

    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('Users')

    response = table.put_item(
       Item={
            'username':'nigel.haney27@gmail.com',
            'usertype':'reporter',
            'totalReports':0,
            'lastReport':"None",
            'ridList':" "
        }
    )

    print("PutItem succeeded:")
    # print(json.dumps(response, indent=4, cls=DecimalEncoder))

if __name__ == '__main__':
    import doctest
    doctest.testmod()
