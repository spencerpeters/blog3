#!/bin/bash

TODAYSDATE=`date +%F`
INTENDEDDAY=$2
YEARMONTH=${TODAYSDATE%??}
INTENDEDDATE="$YEARMONTH$INTENDEDDAY"
TITLEWITHSPACES=$1
FILETITLE=${TITLEWITHSPACES// /-}
RESULT="---\ntitle: $TITLEWITHSPACES\nauthor: Spencer\n---"
echo -e $RESULT >> "./zurich/posts/$INTENDEDDATE-$FILETITLE.markdown"
