import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitor-counter')

def lambda_handler(event, context):
    if event.get('requestContext', {}).get('http', {}).get('method') == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': ''
        }

    response = table.update_item(
        Key={'id': 'visitors'},
        UpdateExpression='SET visit_count = if_not_exists(visit_count, :start) + :inc',
        ExpressionAttributeValues={':inc': 1, ':start': 0},
        ReturnValues='UPDATED_NEW'
    )

    count = int(response['Attributes']['visit_count'])

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        },
        'body': json.dumps({'count': count})
    }
