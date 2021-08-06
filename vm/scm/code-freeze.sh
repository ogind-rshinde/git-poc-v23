#!/bin/bash

read -r -p "$(tput setaf 3) Enter code freeze branch name : " freezeBranch
tput setaf 7
git fetch origin
echo "$(tput setaf 3)creating a new code freeze branch $(tput setaf 7)"
git checkout --no-track -b "$freezeBranch" origin/main
git push origin "$freezeBranch"
echo "$(tput setaf 3)creating a PR from code freeze branch$(tput setaf 7) to release/next"
releaseBranch='release/next'
gh pr create -B "$releaseBranch" -w
