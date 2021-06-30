#!/usr/bin/env bash

## This script executes sequence of git commands which result with current branch being updated with latest master changes and all commits squashed into 1 single commit

FEATURE_BRANCH_NAME=$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)

if [[ $# -ne 2 ]] ; then
    echo "Please provide commit message of squashed changes as first arg to script and parent branch name as second arg"
    exit 1
fi

## updating current branch with latest master changes
git fetch && git merge origin/"$2" || exit 1

## updating local master branch with latest changes
git checkout origin/"$2" && git pull origin "$2" || exit 1

## checking out temporary branch used for squashing
git checkout -b temp-${FEATURE_BRANCH_NAME} || exit 1

## merging squashed feature branch into temporary branch
git merge --squash $FEATURE_BRANCH_NAME || exit 1

## commiting all changes from feature branch into one commit with message specified in arg $1
git add . && git commit -m "$1" || exit 1

## deleting feature branch with unsquashed commits from local repository
git branch -D $FEATURE_BRANCH_NAME || exit 1

## creating new feature branch from our temporary branch with same name as before
git checkout -b $FEATURE_BRANCH_NAME || exit 1

## force pushing squashed feature branch to remote. Can be optionally commented out
##git push origin +$FEATURE_BRANCH_NAME || exit 1

## deleting temporary branch
git branch -D temp-${FEATURE_BRANCH_NAME} || exit 1

echo "updated, squashed and force pushed to remote"
exit 0
