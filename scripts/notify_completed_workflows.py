#!/usr/bin/python

import argparse
import json
import requests

parser = argparse.ArgumentParser(description='Launch notifications of completed Rosetta workflow.')
parser.add_argument('--hostname', dest='hostname', default="https://backend.media-io.com",
				   help='hostname of the SubTiL backend platform')
parser.add_argument('--username', dest='username', required=True,
				   help='username to login to the SubTiL backend platform')
parser.add_argument('--password', dest='password', required=True,
				   help='password to login to the SubTiL backend platform')
parser.add_argument('--date', dest='date', required=True,
				   help='Date filter of creation workflow')
parser.add_argument('--simulate', action='store_true',
				   help='don\'t post the notification, just build and print body')

si_video_url = 'https://gatewayvf.webservices.francetelevisions.fr/v1/videos?qid={}'
args = parser.parse_args()

def get_token():
	payload = {
		"session": {
			"email": args.username,
			"password": args.password
		}
	}

	request = requests.post(args.hostname + "/api/sessions", json=payload)
	response = request.json()

	if not 'access_token' in response:
		print('unable to login')
		exit()

	return response['access_token']

def get_parameter_value(token, key):
	params = {"key": key}
	headers = {'Authorization': token}
	request = requests.get(args.hostname + "/api/credentials", headers=headers, params=params)
	return request.json()['data'][0]['value']

def get_workflows(token, page):
	params = {
		'size': 5000,
		'after_date': args.date,
		'before_date': args.date,
		'page': page,
		'state[]': 'completed',
		'workflow_ids[]':'FranceTV Studio Ingest Rosetta'
	}

	headers = {'Authorization': token}
	request = requests.get(args.hostname + "/api/workflows", headers=headers, params=params)
	response = request.json()

	for workflow in response['data']:
		print('### process video {}'.format(workflow['reference']))

		ttml_filename = None
		mp4_filename = None
		
		for job in workflow['jobs']:
			if(job['name'] == 'upload_ftp'):
				if 'list' in job['params']:
					for parameter in job['params']['list']:
						if(parameter['id'] == 'destination_path'):
							if(parameter['value'].endswith('.mp4')):
								mp4_filename = parameter['value']
							if(parameter['value'].endswith('.ttml')):
								ttml_filename = parameter['value']

		metadata = requests.get(si_video_url.format(workflow['reference'])).json()
		metadata = metadata[0]

		payload = {
			'title': metadata['title'],
			'additional_title': metadata['additional_title'],
			'duration': metadata['duration'],
			'expected_duration': metadata['expected_duration'],
			'expected_at': metadata['expected_at'],
			'broadcasted_at': metadata['broadcasted_at'],
			'legacy_id': metadata['legacy_id'],
			'oscar_id': metadata['oscar_id'],
			'aedra_id': metadata['aedra_id'],
			'plurimedia_broadcast_id': metadata['plurimedia_broadcast_id'],
			'plurimedia_collection_ids': metadata['plurimedia_collection_ids'],
			'plurimedia_program_id': metadata['plurimedia_program_id'],
			'ftvcut_id': metadata['ftvcut_id'],
			'channel': metadata['channel']['id'],
			'ttml_path': ttml_filename,
			'mp4_path': mp4_filename,
		}

		notification_endpoint = get_parameter_value(token, 'ATTESOR_FTVACCESS_ENDPOINT')
		notification_token = get_parameter_value(token, 'ATTESOR_FTVACCESS_TOKEN')

		headers = {'Authorisation': 'Bearer {}'.format(notification_token)}

		if(args.simulate):
			print('notification body: {}'.format(json.dumps(payload)))
		else:
			request = requests.post(notification_endpoint, json=payload, headers=headers)
			if(request.status_code == 200):
				print("--> OK")
			else:
				print("--> ERROR")

token = get_token()

# get_workflows(token, 200)
get_workflows(token, 0)
