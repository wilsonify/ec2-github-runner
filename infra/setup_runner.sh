#!/bin/bash
sudo yum update -y
sudo yum install -y docker git libicu
sudo systemctl start docker
sudo systemctl enable docker

# Set up GitHub Actions Runner
RUNNER_VERSION="2.304.0"
RUNNER_ARCH="linux-x64"
GITHUB_TOKEN="${GITHUB_TOKEN}"

mkdir actions-runner && cd actions-runner
curl -o actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz
tar xzf ./actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

./config.sh --url https://github.com/your-repo-owner/your-repo --token ${GITHUB_TOKEN}

sudo ./svc.sh install
sudo ./svc.sh start
