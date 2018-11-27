#! /usr/bin/env bash

REF_REPO=$1
REMOTE_REPO=$2
LOCAL_WORKSPACE=$3


if [ -z $1 -o -z $2 -o -z $3 ]; then
    echo "invalid call pull-repo.sh '$1' '$2' '$3'"
elif [ ! -d $LOCAL_WORKSPACE ]; then
    git clone --reference $REF_REPO $REMOTE_REPO $LOCAL_WORKSPACE
    cd $LOCAL_WORKSPACE
    git repack -a
else
    cd $LOCAL_WORKSPACE
    git fetch --all --tags
    cd -
fi
