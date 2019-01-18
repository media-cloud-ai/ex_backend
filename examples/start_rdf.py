import requests
import sys

hostname = "http://localhost:4000"
mi_hostname = "http://localhost:4001"

video_id = sys.argv[1]

session = {
    "session": {
        "email": "admin@media-io.com",
        "password": "admin123"
    }
}
access_token = requests.post(hostname + '/api/sessions', json=session).json()["access_token"]

headers = {
    "Authorization": access_token,
}
workflow_order = {
    "workflow": {
        "reference": video_id,
        "flow": {
            "steps": [{
                "id": 1,
                "name": "push_rdf",
                "parameters": [
                    {
                        "id": "perfect_memory_username",
                        "type": "credential",
                        "value": "PERFECT_MEMORY_USERNAME"
                    },
                    {
                        "id": "perfect_memory_password",
                        "type": "credential",
                        "value": "PERFECT_MEMORY_PASSWORD"
                    },
                    {
                        "id": "perfect_memory_endpoint",
                        "type": "credential",
                        "value": "PERFECT_MEMORY_ENDPOINT"
                    }
                ]
            }]
        }
    }
}
print(workflow_order)
response = requests.post(hostname + '/api/workflows', headers=headers, json=workflow_order)
print(response.text)
if response.status_code == 201:
    print("STARTED")
else:
    print(response)
