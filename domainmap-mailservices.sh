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
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/results/dot/mxip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/results/dot/mx.dot"
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
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/results/dot/mxip24.dot"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/results/dot/emailcountry.dot"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/results/dot/mailAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/mailAS.csv"
 echo "$line,$server,$AS" >> "$FOLDER/results/mysql/mail-ip-as-mysql.csv"
 done
 done
done < domains

#Make dot files
#ASNUMBER
cat "$FOLDER/results/dot/mailAS.dot"|sort|uniq >> "$FOLDER/results/dot/mailAS.tmp"
rm "$FOLDER/results/dot/mailAS.dot"
echo "digraph mailserversAS {" > "$FOLDER/results/dot/mailAS.dot"
cat "$FOLDER/results/dot/mailAS.tmp" >> "$FOLDER/results/dot/mailAS.dot"
echo "}" >> "$FOLDER/results/dot/mailAS.dot"

#MX-RECORD
cat "$FOLDER/results/dot/mx.dot"|sort|uniq >> "$FOLDER/results/dot/mx.tmp"
rm "$FOLDER/results/dot/mx.dot"
echo "digraph mailservers {" > "$FOLDER/results/dot/mx.dot"
cat "$FOLDER/results/dot/mx.tmp" >> "$FOLDER/results/dot/mx.dot"
echo "}" >> "$FOLDER/results/dot/mx.dot"

#COUNTRY
cat "$FOLDER/results/dot/emailcountry.dot"|sort|uniq >> "$FOLDER/results/dot/emailcountry.tmp"
rm "$FOLDER/results/dot/emailcountry.dot"
echo "digraph mailcountry {" > "$FOLDER/results/dot/emailcountry.dot"
cat "$FOLDER/results/dot/emailcountry.tmp" >> "$FOLDER/results/dot/emailcountry.dot"
echo "}" >> "$FOLDER/results/dot/emailcountry.dot"

#MX RECORD IP
cat "$FOLDER/results/dot/mxip.dot"|sort|uniq >> "$FOLDER/results/dot/mxip.tmp"
rm "$FOLDER/results/dot/mxip.dot"
echo "digraph mailserversIP {" > "$FOLDER/results/dot/mxip.dot"
cat "$FOLDER/results/dot/mxip.tmp" >> "$FOLDER/results/dot/mxip.dot"
echo "}" >> "$FOLDER/results/dot/mxip.dot"

#MX RECORD IP /24
cat "$FOLDER/results/dot/mxip24.dot"|sort|uniq >> "$FOLDER/results/dot/mxip24.tmp"
rm "$FOLDER/results/dot/mxip24.dot"
echo "digraph mailserversIP24 {" > "$FOLDER/results/dot/mxip24.dot"
cat "$FOLDER/results/dot/mxip24.tmp" >> "$FOLDER/results/dot/mxip24.dot"
echo "}" >> "$FOLDER/results/dot/mxip24.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#SERVERS

$DOT -Tsvg -Kfdp "$FOLDER/results/dot/mx.dot" -o $FOLDER/results/"mx"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/mx.dot" -o $FOLDER/results/"mx"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/mx.dot" -o $FOLDER/results/"mx"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/mx.dot" -o $FOLDER/results/"mx"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/mx.dot" -o $FOLDER/results/"mx"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/mx.dot" -o $FOLDER/results/"mx"-sfdp.svg

#IP
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/mxip.dot" -o $FOLDER/results/"mxip"-fdp.svg
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/mxip24.dot" -o $FOLDER/results/"mxip24"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/mxip.dot" -o $FOLDER/results/"mxip"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/mxip.dot" -o $FOLDER/results/"mxip"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/mxip.dot" -o $FOLDER/results/"mxip"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/mxip.dot" -o $FOLDER/results/"mxip"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/mxip.dot" -o $FOLDER/results/"mxip"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/emailcountry.dot" -o $FOLDER/results/"emailcountry"-sfdp.svg


#AS
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/mailAS.dot" -o $FOLDER/results/"mailAS"-sfdp.svg

rm "$FOLDER/results/dot/emailcountry.tmp"
rm "$FOLDER/results/dot/mxip.tmp"
rm "$FOLDER/results/dot/mx.tmp"
rm "$FOLDER/results/dot/mailAS.tmp"

printf "Done\n"
exit 0
