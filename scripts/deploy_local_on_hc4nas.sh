#!/bin/sh
PUBDIR=public/
DIR=/mnt/website/   # the directory where your web site files should go


git fetch --all
git pull
git submodule init
git pull --recurse-submodules


docker run --rm -it -v $PWD:/src klakegg/hugo  && rsync -avz --delete ${PUBDIR} ${DIR}

exit 0

