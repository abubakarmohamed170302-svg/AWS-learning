# Replace <api-id> with your own API Gateway API ID.

Invoke-RestMethod `
  -Method POST `
  -Uri "https://<api-id>.execute-api.eu-west-2.amazonaws.com/submit" `
  -ContentType "application/json" `
  -Body '{"name":"Abubakar","module":"AWS Assignment 4"}'
