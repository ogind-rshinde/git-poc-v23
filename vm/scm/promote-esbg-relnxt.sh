#!/bin/bash

echo "Executing command: git rev-parse --abbrev-ref HEAD"
BRANCH=$(git rev-parse --abbrev-ref HEAD)

threeMonthLastDate=$(date --date="90 days ago" +"%Y-%m-%d")

if ! gh --version; then
  echo "$(tput setaf 1)ERROR: GH tool is not installed, Please install!"
  exit
fi

echo "$(tput setaf 7)Executing command: git fetch origin"
git fetch origin

branchType=${BRANCH:0:4}
if [[ "$branchType" == "esbg" ]]; then

  read -r -p "Please enter correct commid ID of PR number: " commitID

  #Create a esrn branch from origin/release/next
  esrnBranchName="${BRANCH/esbg/esrn}"
  echo "$(tput setaf 7)Executing command: git checkout -b $esrnBranchName origin/release/next"
  if ! git checkout --no-track -b "$esrnBranchName" origin/release/next; then
    echo "$(tput setaf 1)ERROR: Failed to create esrn branch!"
    exit
  fi

  echo "$(tput setaf 7)Executing command: git cherry-pick $commitID"
  if ! git cherry-pick "$commitID"; then
    echo "$(tput setaf 1)ERROR: Failed to cherry-pick!"
    exit
  fi

  git push origin "$esrnBranchName" -f
  releaseBranch='release/next'
  gh pr create -t "Merge esrn branch for $BRANCH to release/next branch" -b "esrn PR merge to release/next branch" -B "$releaseBranch"
  git checkout "$BRANCH"

elif [[ "$branchType" == "esrn" ]]; then
  # TODO: generate the PR if not already generated for esrn branch
  prNumber=$(gh pr list --base release/next -s all --search "created:>$threeMonthLastDate" | grep "$BRANCH" | cut -d $'\t' -f1)
  if [[ "$prNumber" != "" ]]; then
    echo "$(tput setaf 1)ERROR: PR is already exist for this branch!"
    exit
  fi

  echo "$(tput setaf 6) Pushing the changes to branch..."
  git push origin "$BRANCH"

  while true; do
    read -r -p "$(tput setaf 3)Do you want generate PR for release/next branch? yes/no: " prValid
    case $prValid in
    [Yy]*) break ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
  done
  releaseBranch='release/next'
  gh pr create -t "Merge esrn branch for $BRANCH to release/next branch" -b "esrn PR merge to release/next branch" -B "$releaseBranch"

else
  echo "$(tput setaf 1) ***** This script is applicable only for esbg branches! **** "
  exit
fi
