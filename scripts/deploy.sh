#!/bin/sh
HOST=jwupf.net
PUBDIR=public/
DIR=jwupf.net/   # the directory where your web site files should go

hugo  && rsync -avz --delete ${PUBDIR} ${HOST}:${DIR}

exit 0

