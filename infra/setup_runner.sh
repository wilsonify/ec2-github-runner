#!/bin/bash
set -e
sudo yum update -y
sudo yum install -y docker git libicu
sudo systemctl start docker
sudo systemctl enable docker

# Set up GitHub Actions Runner
RUNNER_VERSION="2.319.1"
RUNNER_ARCH="linux-x64"

mkdir actions-runner && cd actions-runner
curl -o actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz
echo "3f6efb7488a183e291fc2c62876e14c9ee732864173734facc85a1bfb1744464  actions-runner-linux-x64-2.319.1.tar.gz" | sha256sum -c -
tar xzf ./actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

./config.sh --unattended --url https://github.com/wilsonify/FreshInstall --token $GITHUB_TOKEN --labels self-hosted Linux X64 064592191516

sudo ./svc.sh install
sudo ./svc.sh start
