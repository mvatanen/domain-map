#https://github.com/mvatanen

#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/mxip
FOLDER=$cur/$PROJECT/mxip
mkdir $FOLDER/ip
mkdir -p $FOLDER/results/mysql

#DNS MX-records
while read line; do dig MX +tries=5 $(idn2 $line) +short|awk {'print tolower ($2)'}>>$FOLDER/$line;sleep 0.2;done <domains

#IP
while read line
do
 for servername in `cat "$FOLDER/$line"`
 do
 for serverip in `dig $servername +short|awk {'print tolower($1)'}`
 do
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/mxip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/mx.dot"
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
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/mxip24.dot"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/emailcountry.dot"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/mailAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/mailAS.csv"
 echo "$line,$server,$AS" >> "$FOLDER/results/mysql/mail-ip-as-mysql.csv"
 done
 done
done < domains

#Make dot files
#ASNUMBER
cat "$FOLDER/mailAS.dot"|sort|uniq >> "$FOLDER/mailAS.tmp"
rm "$FOLDER/mailAS.dot"
echo "digraph mailserversAS {" > "$FOLDER/mailAS.dot"
cat "$FOLDER/mailAS.tmp" >> "$FOLDER/mailAS.dot"
echo "}" >> "$FOLDER/mailAS.dot"

#MX-RECORD
cat "$FOLDER/mx.dot"|sort|uniq >> "$FOLDER/mx.tmp"
rm "$FOLDER/mx.dot"
echo "digraph mailservers {" > "$FOLDER/mx.dot"
cat "$FOLDER/mx.tmp" >> "$FOLDER/mx.dot"
echo "}" >> "$FOLDER/mx.dot"

#COUNTRY
cat "$FOLDER/emailcountry.dot"|sort|uniq >> "$FOLDER/emailcountry.tmp"
rm "$FOLDER/emailcountry.dot"
echo "digraph mailcountry {" > "$FOLDER/emailcountry.dot"
cat "$FOLDER/emailcountry.tmp" >> "$FOLDER/emailcountry.dot"
echo "}" >> "$FOLDER/emailcountry.dot"

#MX RECORD IP
cat "$FOLDER/mxip.dot"|sort|uniq >> "$FOLDER/mxip.tmp"
rm "$FOLDER/mxip.dot"
echo "digraph mailserversIP {" > "$FOLDER/mxip.dot"
cat "$FOLDER/mxip.tmp" >> "$FOLDER/mxip.dot"
echo "}" >> "$FOLDER/mxip.dot"

#MX RECORD IP /24
cat "$FOLDER/mxip24.dot"|sort|uniq >> "$FOLDER/mxip24.tmp"
rm "$FOLDER/mxip24.dot"
echo "digraph mailserversIP24 {" > "$FOLDER/mxip24.dot"
cat "$FOLDER/mxip24.tmp" >> "$FOLDER/mxip24.dot"
echo "}" >> "$FOLDER/mxip24.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#SERVERS

$DOT -Tsvg -Kfdp "$FOLDER/mx.dot" -o $FOLDER/results/"mx"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/mx.dot" -o $FOLDER/results/"mx"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/mx.dot" -o $FOLDER/results/"mx"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/mx.dot" -o $FOLDER/results/"mx"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/mx.dot" -o $FOLDER/results/"mx"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/mx.dot" -o $FOLDER/results/"mx"-sfdp.svg

#IP
$DOT -Tsvg -Kfdp "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip"-fdp.svg
$DOT -Tsvg -Kfdp "$FOLDER/mxip24.dot" -o $FOLDER/results/"mxip24"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry"-sfdp.svg


#AS
$DOT -Tsvg -Kfdp "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS"-sfdp.svg

rm "$FOLDER/emailcountry.tmp"
rm "$FOLDER/mxip.tmp"
rm "$FOLDER/mx.tmp"
rm "$FOLDER/mailAS.tmp"

printf "Done\n"
exit 0
