#!/usr/bin/env fish
echo "copying statistics for job $USE_BUILD_URL"
curl --user "$USER:$PASSWORD" --insecure -o build.json "$USE_BUILD_URL//api/json?pretty=true&depth=100"

echo "to collection 'jobs'"
curl --user "$USER:$PASSWORD" --insecure --header 'accept: application/json' --data-binary @build.json --dump - -X POST "$CLOUD_URL/_api/document/jobs"
