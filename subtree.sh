#!/bin/bash

### This file is for easily adding or pulling from subtrees

### CMD = "add" or "pull"
### PROJ = the name of the project in our emacs lib e.g. "magit" or "dash"
### REMOTE = either fully qualified clone link or named remote
CMD=$1
PROJ=$2
REMOTE=$3

### Run the stuff! ALWAYS squash
git subtree $CMD --prefix=lib/$PROJ $REMOTE master --squash

if [ $CMD = add ]
then
    echo $REMOTE lib/$PROJ/.remote
fi
