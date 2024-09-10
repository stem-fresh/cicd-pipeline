#!/bin/bash

# -e Exit immediately if any command fails
# -x Echo output to the stdout
set -e -x

if [[ "$GITHUB_REF" == "refs/heads/dev" ]]; then
  echo "GCP_PROJECT_ID=${{ secrets.GCP_DEV_PROJECT_ID }}" >> $GITHUB_ENV
  echo "GCP_SA_KEY=${{ secrets.GCP_DEV_SA_KEY }}" >> $GITHUB_ENV
elif [[ "$GITHUB_REF" == "refs/heads/main" ]]; then
  echo "GCP_PROJECT_ID=${{ secrets.GCP_PROD_PROJECT_ID }}" >> $GITHUB_ENV
  echo "GCP_SA_KEY=${{ secrets.GCP_DEV_PROD_KEY }}" >> $GITHUB_ENV
fi



