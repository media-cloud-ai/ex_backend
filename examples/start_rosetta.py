import requests
import sys

hostname = "http://localhost:4000"

video_id = sys.argv[1]

session = {
    "session": {
        "email": "admin@media-io.com",
        "password": "admin123"
    }
}
access_token = requests.post(hostname + '/api/sessions', json=session).json()["access_token"]

headers = {
    "Authorization": access_token
}
workflow_order = {
    "reference": video_id,
}
print(workflow_order)
response = requests.post(hostname + '/api/workflow/ingest-rosetta', headers=headers, json=workflow_order)
print(response.text)
if response.status_code == 200:
    print("STARTED")
else:
    print(response)
