#!/bin/sh
HOST=jwupf.net
PUBDIR=public/
DIR=jwupf.net/   # the directory where your web site files should go

git fetch --all
git pull
git submodule init
git pull --recurse-submodules

hugo  && rsync -avz --delete ${PUBDIR} ${HOST}:${DIR}

exit 0

