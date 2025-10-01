#!/bin/bash
source .env
docker run -d -p 3000:8080 -e OPENAI_API_KEY=$secret_key -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
