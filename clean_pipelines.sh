#!/bin/bash
read -sp 'GitLab Token: ' TOKEN
echo
PROJECT="14964605"
for PIPELINE in $(curl -s --header "PRIVATE-TOKEN: ${TOKEN}" "https://gitlab.com/api/v4/projects/${PROJECT}/pipelines" | jq '.[].id'); do
  echo $PIPELINE
  curl --header "PRIVATE-TOKEN: ${TOKEN}" --request "DELETE" "https://gitlab.com/api/v4/projects/${PROJECT}/pipelines/${PIPELINE}"
  sleep 1
done
