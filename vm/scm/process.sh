#!/bin/bash

USERNAME=$(git config user.userid)

#branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

echo "$(tput setaf 2) What do you want to do?
1 - Branch Creation
2 - Generate PR for main branch
3 - Release changes of QABG branch to release/next branch
4 - Release hotfix changes to release/next branch
5 - Release hotfix changes to hotfix/next branch
6 - code freeze"

while :; do
  read -r -p "Select the type which want perform action: " branchOption
  [[ $branchOption =~ ^[0-9]+$ ]] || {
    echo "Enter a valid number"
    continue
  }
  if ((branchOption >= 1 && branchOption <= 5)); then
    break
  else
    echo "$(tput setaf 1) ******* Selected number is out of range. Try again!"
  fi
done

echo "$(tput setaf 3) "

if test "$branchOption" = 1; then
  source ./vm/scm/creat-branch.sh
elif test "$branchOption" = 2; then
  sh ./vm/scm/sync-branch.sh
elif test "$branchOption" = 3; then
  sh ./vm/scm/promote-qabg-relnxt.sh
elif test "$branchOption" = 4; then
  sh ./vm/scm/promote-hfbg-relnxt.sh
elif test "$branchOption" = 5; then
  sh ./vm/scm/promote-hfbg-hfxnxt.sh
elif test "$branchOption" = 6; then
  sh ./vm/scm/code-freeze.sh
fi
