import requests
import sys

hostname = "http://localhost:4000"
mi_hostname = "http://localhost:4001"

video_id = sys.argv[1]

session = {
    "session": {
        "email": "admin@media-cloud.ai",
        "password": "admin123"
    }
}
access_token = requests.post(hostname + '/api/sessions', json=session).json()["access_token"]

query = {
    "external_ids.video_id": video_id
}
files = requests.get(mi_hostname + '/api/files', params=query).json()

videos = []
ttml_path = ""

for file in files:
    if file['format']['mime_type'] == 'video/mp4':
        path = file['path'] + file['filename']
        if path.startswith('/343079/http/'):
            path = path.replace('/343079/http', '')
        videos.append(path)
        continue
    if file['format']['mime_type'] == 'application/xml+ttml':
        ttml_path = file['url']
        continue

headers = {
    "Authorization": access_token
}
workflow_order = {
    "reference": video_id,
    "mp4_paths": videos,
    "ttml_path": ttml_path,
}
print(workflow_order)
response = requests.post(hostname + '/api/workflow/ingest-dash', headers=headers, json=workflow_order)
print(response.text)
if response.status_code == 200:
    print("STARTED")
else:
    print(response)
