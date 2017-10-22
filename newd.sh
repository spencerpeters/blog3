#!/bin/bash

DATE=`date +%F`
TITLEWITHSPACES=$1
RESULT="---\ntitle: $TITLEWITHSPACES\nauthor: Spencer\n---"
FILETITLE=${TITLEWITHSPACES// /-}
mkdir ./zurich/posts/$DATE-$FILETITLE
mkdir ./zurich/posts/$DATE-$FILETITLE/images
echo -e $RESULT >> "./zurich/posts/$DATE-$FILETITLE/$DATE-$FILETITLE.markdown"