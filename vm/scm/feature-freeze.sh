#!/bin/bash

read -r -p "$(tput setaf 3) Enter feature freeze branch name : " freezeBranch
echo "$(tput setaf 7)"
git checkout main
echo "$(tput setaf 3)update the main branch $(tput setaf 7)"
git pull origin main
echo "$(tput setaf 3)creating a new feature branch $(tput setaf 7)"
git checkout -b "$freezeBranch"
git push origin "$freezeBranch"
echo "$(tput setaf 3)creating a PR on new feature freeze branch$(tput setaf 7)"
releaseBranch='release/next'
gh pr create -t "Merge qarn branch for $freezeBranch to release/next branch" -b "feature freeze PR merge to release/next branch" -B "$releaseBranch"