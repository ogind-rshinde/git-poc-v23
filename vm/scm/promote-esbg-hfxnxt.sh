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

  #Create a eshn branch from origin/hotfix/next
  eshnBranchName="${BRANCH/esbg/eshn}"
  echo "$(tput setaf 7)Executing command: git checkout -b $eshnBranchName origin/hotfix/next"
  if ! git checkout --no-track -b "$eshnBranchName" origin/hotfix/next; then
    echo "$(tput setaf 1)ERROR: Failed to create eshn branch!"
    exit
  fi

  echo "$(tput setaf 7)Executing command: git cherry-pick $commitID"
  if ! git cherry-pick "$commitID"; then
    echo "$(tput setaf 1)ERROR: Failed to cherry-pick!"
    exit
  fi

  git push origin "$eshnBranchName" -f
  releaseBranch='hotfix/next'
  gh pr create -t "Merge eshn branch for $BRANCH to hotfix/next branch" -b "eshn PR merge to hotfix/next branch" -B "$releaseBranch"
  git checkout "$BRANCH"

elif [[ "$branchType" == "eshn" ]]; then
  # TODO: generate the PR if not already generated for eshn branch
  prNumber=$(gh pr list --base hotfix/next -s all --search "created:>$threeMonthLastDate" | grep "$BRANCH" | cut -d $'\t' -f1)
  if [[ "$prNumber" != "" ]]; then
    echo "$(tput setaf 1)ERROR: PR is already exist for this branch!"
    exit
  fi

  echo "$(tput setaf 6) Pushing the changes to branch..."
  git push origin "$BRANCH"

  while true; do
    read -r -p "$(tput setaf 3)Do you want generate PR for hotfix/next branch? yes/no: " prValid
    case $prValid in
    [Yy]*) break ;;
    [Nn]*) exit ;;
    *) echo "Please answer yes or no." ;;
    esac
  done
  hotfixBranch='hotfix/next'
  gh pr create -t "Merge eshn branch for $BRANCH to hotfix/next branch" -b "eshn PR merge to hotfix/next branch" -B "$hotfixBranch"

else
  echo "$(tput setaf 1) ***** This script is applicable only for esbg branches! **** "
  exit
fi
