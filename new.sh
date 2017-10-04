#!/bin/bash

DATE=`date +%F`
TITLEWITHSPACES=$1
RESULT="---\ntitle: $TITLEWITHSPACES\nauthor: Spencer\n---"
FILETITLE=${TITLEWITHSPACES// /-}
echo -e $RESULT >> "./zurich/posts/$DATE-$FILETITLE.markdown"