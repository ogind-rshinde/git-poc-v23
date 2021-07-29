#!/bin/bash


read -r -p "$(tput setaf 3) Enter a tag name : " tagname
echo " tag is creating and pushing to github"
echo "$(tput setaf 7)"
git push origin "$tagname"

read -r -p "$(tput setaf 3) Enter production release branch name : " freezeBranch

echo "$(tput setaf 7)"
git checkout -b "$freezeBranch" origin/"$tagname"
git push origin "$freezeBranch"

echo "$(tput setaf 3)creating a PR on new production release branch$(tput setaf 7)"
releaseBranch='hotfix/next'
gh pr create -t "Merge qarn branch for $freezeBranch to hotfix/next branch" -b "production release PR merge to hotfix/next branch" -B "$releaseBranch"