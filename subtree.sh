#!/bin/bash

### This file is for easily adding or pulling from subtrees

### CMD = "add" or "pull"
### PROJ = the name of the project in our emacs lib e.g. "magit" or "dash"
### REMOTE = either fully qualified clone link or named remote
CMD=$1
PROJ=$2
### Since in latter cases, the remote will be named after the proj,
### allow for simply writing CMD PROJ
REMOTE=${3:-$PROJ}
### NOTE: we may NOT avail ourselves of the CMD PROJ only pattern
### if we want to have a non-default tag at $4.
### I don't plan on that happening any time soon so I don't care about the edge case.
TAG=${4:-"master"}

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
