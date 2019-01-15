
HOSTNAME=http://localhost:4000
MIO_TOKEN=`curl -H "Content-Type: application/json" -d '{"session": {"email": "admin@media-io.com", "password": "admin123"} }' $HOSTNAME/api/sessions | jq -r ".access_token"`
curl -H "Authorization: $MIO_TOKEN" -H "Content-Type: application/json" -d '{"reference": "bbbcd067-9013-4b69-a77d-6d36d08726b3", "mp4_path": "/streaming-adaptatif/2018/S50/J1/194051816-5c0da7019bcbe-standard1.mp4", "ttml_path": "https://staticftv-a.akamaihd.net/sous-titres/2018/12/10/194051816-5c0da7019bcbe-1544399640.ttml", "dash_manifest_url": "http://videos-pmd.francetv.fr/innovation/SubTil/bbbcd067-9013-4b69-a77d-6d36d08726b3/2019_01_15__08_55_58/manifest.mpd"}' $HOSTNAME/api/workflow/acs
