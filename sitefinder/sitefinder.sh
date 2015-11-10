#!/bin/bash

USERAGENT=( "Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1") 
while read line
do
RESULT=$(curl -Gs \
    -d v=1.0 \
    -d start=0 \
    -d rsz=3 \
    -A "${USERAGENT}" \
    --data-urlencode q="$line" \
    http://ajax.googleapis.com/ajax/services/search/web| sed 's/"unescapedUrl":"\([^"]*\).*/\1/;s/.*GwebSearch",//')
echo "$line ;$RESULT" >> search_results.txt
#sleep $[ ( $RANDOM % 60 )  + 30 ]s
sleep 90
done < find_these
