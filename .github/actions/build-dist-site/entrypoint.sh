#!/usr/bin/env bash

set -e

echo "Starting deployment..."
# REMOTE_REPO="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
# REMOTE_REPO="https://x-access-token:${PERSONAL_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
SSH_DIR=/root/.ssh
mkdir "${SSH_DIR}"
ssh-keyscan -t rsa github.com > "${SSH_DIR}/known_hosts"
echo "${ACTIONS_DEPLOY_KEY}" > "${SSH_DIR}/id_rsa"
chmod 400 "${SSH_DIR}/id_rsa"
REMOTE_REPO="git@github.com:${GITHUB_REPOSITORY}.git"

git clone -b source $REMOTE_REPO repo
cd repo

echo "Installing dependencies..."
bundle install

echo "Building website..."
/bin/sh ./updategitinfo.sh
JEKYLL_ENV=production bundle exec jekyll build --trace
echo "Jekyll build done"

cd build
echo "Publishing website"
rm -f README.md

git init
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git add .

git commit -m "Github Actions - $(date)"
echo "Build branch ready to go. Pushing to Github..."

git push --force $REMOTE_REPO master

rm -rf .git
cd ..
rm -rf repo
echo "Deployed!"
