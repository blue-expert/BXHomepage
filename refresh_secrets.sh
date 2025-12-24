#!/bin/bash

# --- CONFIGURATION ---
PARENT_SECRET_NAME="secret-confident-euler"
PROJECT_ID="4ee5eb9c-23f5-494a-8328-acd6ed653011"
REGION="nl-ams"
# ---------------------

echo "1. Finding Secret ID..."
SECRET_ID=$(scw secret secret list name="$PARENT_SECRET_NAME" project-id="$PROJECT_ID" region="$REGION" -o json | jq -r '.[0].id')

if [ -z "$SECRET_ID" ] || [ "$SECRET_ID" == "null" ]; then
    echo "Error: Could not find secret '$PARENT_SECRET_NAME'."
    exit 1
fi

echo "   Found ID: $SECRET_ID"

echo "2. Fetching and Decoding Payload..."

# Step A: Get the full JSON object for the secret version
# We use '-o json' to get the raw API response.
FULL_JSON=$(scw secret version access "$SECRET_ID" revision=latest region="$REGION" -o json)

# Step B: Extract the 'data' field (which is Base64 encoded)
B64_DATA=$(echo "$FULL_JSON" | jq -r '.data')

if [ -z "$B64_DATA" ] || [ "$B64_DATA" == "null" ]; then
    echo "Error: Could not extract data from secret response."
    echo "Debug Info: $FULL_JSON"
    exit 1
fi

# Step C: Decode Base64 to get the actual text
PAYLOAD=$(echo "$B64_DATA" | base64 -d)

echo "3. Creating .env file..."
echo "# Auto-generated from Scaleway" > .env

# Parse the decoded JSON payload into .env format
echo "$PAYLOAD" | jq -r 'to_entries[] | "\(.key)=\"\(.value)\""' >> .env

echo "Done! Secrets successfully decoded and saved to .env"
