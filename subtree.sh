#!/bin/bash

### This file is for easily adding or pulling from subtrees

### CMD = "add" or "pull"
### PROJ = the name of the project in our emacs lib e.g. "magit" or "dash"
### REMOTE = either fully qualified clone link or named remote
CMD=$1
PROJ=$2
REMOTE=$3
TAG=${4-"master"}

echo $TAG

git remote add -f $PROJ $REMOTE || true
if [ $CMD = "pull" ]
then
    git fetch $PROJ $TAG
fi

### Run the stuff! ALWAYS squash
git subtree $CMD --prefix=lib/$PROJ $PROJ $TAG --squash

if [ $CMD = "add" ]
then
    echo $REMOTE >> lib/$PROJ/.remote
fi
