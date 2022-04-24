#!/bin/sh
PUBDIR=public/
DIR=/mnt/website/   # the directory where your web site files should go

hugo  && rsync -avz --delete ${PUBDIR} ${DIR}

exit 0

