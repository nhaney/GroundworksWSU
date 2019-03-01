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



def reportToDB(loc, time, photourl, desc, rank, reporter, rid):
    '''
    This function uses the boto3 module
    to add a report to the DynamoDB
    Usage
    >>> reportToDB("740 Stadium Way", "12:15", "photourl.com", "test desc.", 5, "nigel.haney@wsu.edu", 43)
    PutItem succeeded:
    'Added Report to DB. '
    '''

    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('Reports')

    if photourl != "":
        #need to get reportID from table, update it
        response = table.put_item(
           Item={
                'reportID':rid,
                'location':loc,
                'timeReported':time,
                'photo':photourl,
                'description':desc,
                'ranking':rank,
                'whoReported':reporter,
                'currentStatus':'active'
            }
        )
    else:
        response = table.put_item(
           Item={
                'reportID':rid,
                'location':loc,
                'timeReported':time,
                'description':desc,
                'ranking':rank,
                'whoReported':reporter,
                'currentStatus':'active'
            }
        )


    print("PutItem succeeded:")
    # print(json.dumps(response, indent=4, cls=DecimalEncoder))
    return "Added Report to DB. "

if __name__ == "__main__":
    import doctest
    doctest.testmod()