#!/bin/bash

sleep 30

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-463.0.0-linux-x86_64.tar.gz
tar -xf google-cloud-cli-463.0.0-linux-x86_64.tar.gz
rm google-cloud-cli-463.0.0-linux-x86_64.tar.gz

./google-cloud-sdk/install.sh