#https://github.com/mvatanen

#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/mxip
FOLDER=$cur/$PROJECT/mxip
mkdir $FOLDER/ip
mkdir -p $FOLDER/results/mysql
mkdir -p $FOLDER/results/dot

#DNS MX-records
while read line; do dig MX +tries=5 $(idn2 $line) +short|awk {'print tolower ($2)'}>>$FOLDER/$line;sleep 0.2;done <domains

#IP
while read line
do
 for servername in `cat "$FOLDER/$line"`
 do
 for serverip in `dig $servername +short|awk {'print tolower($1)'}`
 do
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/dot/mxip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/dot/mx.dot"
 echo "$line,$serverip" >> "$FOLDER/results/mail-ip.csv"
 echo "$line,$servername" >> "$FOLDER/results/mail-mx.csv"
 echo "$line,$servername,$serverip" >> "$FOLDER/results/mysql/mail-server-ip-mysql.csv"
 echo  $serverip >> "$FOLDER/ip/$line"
 done
 done
done < domains


#IP24
while read line
do
 for servername in `cat "$FOLDER/$line"`
 do
 for serverip in `dig $servername +short| sed 's/\.[0-9]*$/.0/'|awk {'print tolower($1)'}`
 do
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/dot/mxip24.dot"
 echo "$line,$serverip" >> "$FOLDER/results/mail-ip24.csv"
 done
 done
done < domains

  
#Country
while read line
do
 for serverip in `cat "$FOLDER/ip/$line"`
 do
 for country in "`geoiplookup $serverip|grep Country|cut -d ',' -f2-|tr -d "'"|xargs`"
 do
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/dot/emailcountry.dot"
 echo "$line,$country" >> "$FOLDER/results/mailcountry.csv" 
 echo "$line,$serverip,$country" >> "$FOLDER/results/mysql/mail-ip-country-mysql.csv"
 done
 done
done < domains

#AS
while read line
do
 for server in `cat "$FOLDER/ip/$line"` 
 do
 for AS in "`geoiplookup $server|grep ASNum|cut -d ':' -f2-|awk {'print tolower($0)'}|tr -d "'"|xargs`"
 do
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/dot/mailAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/mailAS.csv"
 echo "$line,$server,$AS" >> "$FOLDER/results/mysql/mail-ip-as-mysql.csv"
 done
 done
done < domains

#Make dot files
#ASNUMBER
cat "$FOLDER/dot/mailAS.dot"|sort|uniq >> "$FOLDER/dot/mailAS.tmp"
rm "$FOLDER/dot/mailAS.dot"
echo "digraph mailserversAS {" > "$FOLDER/dot/mailAS.dot"
cat "$FOLDER/dot/mailAS.tmp" >> "$FOLDER/dot/mailAS.dot"
echo "}" >> "$FOLDER/dot/mailAS.dot"

#MX-RECORD
cat "$FOLDER/dot/mx.dot"|sort|uniq >> "$FOLDER/dot/mx.tmp"
rm "$FOLDER/dot/mx.dot"
echo "digraph mailservers {" > "$FOLDER/dot/mx.dot"
cat "$FOLDER/dot/mx.tmp" >> "$FOLDER/dot/mx.dot"
echo "}" >> "$FOLDER/dot/mx.dot"

#COUNTRY
cat "$FOLDER/dot/emailcountry.dot"|sort|uniq >> "$FOLDER/dot/emailcountry.tmp"
rm "$FOLDER/dot/emailcountry.dot"
echo "digraph mailcountry {" > "$FOLDER/dot/emailcountry.dot"
cat "$FOLDER/dot/emailcountry.tmp" >> "$FOLDER/dot/emailcountry.dot"
echo "}" >> "$FOLDER/dot/emailcountry.dot"

#MX RECORD IP
cat "$FOLDER/dot/mxip.dot"|sort|uniq >> "$FOLDER/dot/mxip.tmp"
rm "$FOLDER/dot/mxip.dot"
echo "digraph mailserversIP {" > "$FOLDER/dot/mxip.dot"
cat "$FOLDER/dot/mxip.tmp" >> "$FOLDER/dot/mxip.dot"
echo "}" >> "$FOLDER/dot/mxip.dot"

#MX RECORD IP /24
cat "$FOLDER/dot/mxip24.dot"|sort|uniq >> "$FOLDER/dot/mxip24.tmp"
rm "$FOLDER/dot/mxip24.dot"
echo "digraph mailserversIP24 {" > "$FOLDER/dot/mxip24.dot"
cat "$FOLDER/dot/mxip24.tmp" >> "$FOLDER/dot/mxip24.dot"
echo "}" >> "$FOLDER/dot/mxip24.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#SERVERS

$DOT -Tsvg -Kfdp "$FOLDER/dot/mx.dot" -o $FOLDER/results/"mx"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/mx.dot" -o $FOLDER/results/"mx"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/mx.dot" -o $FOLDER/results/"mx"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/mx.dot" -o $FOLDER/results/"mx"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/mx.dot" -o $FOLDER/results/"mx"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/mx.dot" -o $FOLDER/results/"mx"-sfdp.svg

#IP
$DOT -Tsvg -Kfdp "$FOLDER/dot/mxip.dot" -o $FOLDER/results/"mxip"-fdp.svg
$DOT -Tsvg -Kfdp "$FOLDER/dot/mxip24.dot" -o $FOLDER/results/"mxip24"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/mxip.dot" -o $FOLDER/results/"mxip"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/mxip.dot" -o $FOLDER/results/"mxip"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/mxip.dot" -o $FOLDER/results/"mxip"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/mxip.dot" -o $FOLDER/results/"mxip"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/mxip.dot" -o $FOLDER/results/"mxip"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-sfdp.svg


#AS
$DOT -Tsvg -Kfdp "$FOLDER/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-sfdp.svg

rm "$FOLDER/dot/emailcountry.tmp"
rm "$FOLDER/dot/mxip.tmp"
rm "$FOLDER/dot/mx.tmp"
rm "$FOLDER/dot/mailAS.tmp"

printf "Done\n"
exit 0
