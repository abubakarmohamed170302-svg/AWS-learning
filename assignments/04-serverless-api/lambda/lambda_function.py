import json
import boto3
import uuid
from datetime import datetime, timezone

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("students")

def lambda_handler(event, context):
    try:
        body = event.get("body", event)

        if isinstance(body, str):
            body = json.loads(body)

        student_id = str(uuid.uuid4())
        timestamp = datetime.now(timezone.utc).isoformat()

        item = {
            "id": student_id,
            "timestamp": timestamp,
            "payload": body
        }

        table.put_item(Item=item)

        return {
            "statusCode": 201,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "message": "Student data stored successfully",
                "id": student_id,
                "timestamp": timestamp,
                "payload": body
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({
                "message": "Internal server error",
                "error": str(e)
            })
        }
