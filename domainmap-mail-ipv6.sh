#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/mxip6
FOLDER=$cur/$PROJECT/mxip6
mkdir $FOLDER/ip
mkdir -p $FOLDER/results/mysql

#DNS MX-records ipv6
while read line; do dig MX +tries=5 $(idn2 $line) +short|awk {'print tolower ($2)'}>>$FOLDER/$line;sleep 0.2;done <domains

while read line
do
 for servername in `cat "$FOLDER/$line"`
 do
 if !
 dig AAAA +tries=5 $(idn2 $servername) +short|grep -v $line >/dev/null
 then
 for serverip in `dig AAAA $servername +short|awk {'print tolower($1)'}`
 do
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/mxip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/mx.dot"
 echo "$line,$serverip" >> "$FOLDER/results/mxip6.csv"
 echo "$line,$servername" >> "$FOLDER/results/mx6.csv"
 echo "$line,$servername,$serverip" >> "$FOLDER/results/mysql/mail-server-ip6-mysql.csv"
 echo $serverip >> "$FOLDER/ip/$line"
 done
 fi
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
 echo "$line,$country" >> "$FOLDER/results/mailcountry6.csv"
 echo "$line,$serverip,$country" >> "$FOLDER/results/mysql/mail-ip6-country-mysql.csv"
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
 echo "$line,$AS" >> "$FOLDER/results/mailAS6.csv"
 echo "$line,$server,$AS" >> "$FOLDER/results/mysql/mail-ip6-as-mysql.csv"
 done
 done
done < domains

#Make dot files
cat "$FOLDER/mailAS.dot"|sort|uniq >> "$FOLDER/mailAS.tmp"
rm "$FOLDER/mailAS.dot"
echo "digraph mailserversipv6AS {" > "$FOLDER/mailAS.dot"
cat "$FOLDER/mailAS.tmp" >> "$FOLDER/mailAS.dot"
echo "}" >> "$FOLDER/mailAS.dot"

cat "$FOLDER/mx.dot"|sort|uniq >> "$FOLDER/mx.tmp"
rm "$FOLDER/mxipv6.dot"
echo "digraph mailserversipv6 {" > "$FOLDER/mx.dot"
cat "$FOLDER/mx.tmp" >> "$FOLDER/mx.dot"
echo "}" >> "$FOLDER/mx.dot"

cat "$FOLDER/emailcountry.dot"|sort|uniq >> "$FOLDER/mailcountry.tmp"
rm "$FOLDER/emailcountry.dot"
echo "digraph emailipv6country {" > "$FOLDER/emailcountry.dot"
cat "$FOLDER/emailcountry.tmp" >> "$FOLDER/emailcountry.dot"
echo "}" >> "$FOLDER/emailcountry.dot"

cat "$FOLDER/mxip.dot"|sort|uniq >> "$FOLDER/mxip.tmp"
rm "$FOLDER/mxip.dot"
echo "digraph mailpv6 {" > "$FOLDER/mxip.dot"
cat "$FOLDER/mxip.tmp" >> "$FOLDER/mxip.dot"
echo "}" >> "$FOLDER/mxip.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#SERVERS

$DOT -Tsvg -Kfdp "$FOLDER/mx.dot" -o $FOLDER/results/"mailserversipv6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/mx.dot" -o $FOLDER/results/"mx6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/mx.dot" -o $FOLDER/results/"mx6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/mx.dot" -o $FOLDER/results/"mx6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/mx.dot" -o $FOLDER/results/"mx6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/mx.dot" -o $FOLDER/results/"mx6"-sfdp.svg

#IP6
$DOT -Tsvg -Kfdp "$FOLDER/mxip.dot" -o $FOLDER/results/"mxipv6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/mxip.dot" -o $FOLDER/results/"mxip6"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/emailcountry.dot" -o $FOLDER/results/"mailcountryipv6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/emailcountry.dot" -o $FOLDER/results/"emailcountry6"-sfdp.svg


#AS
$DOT -Tsvg -Kfdp "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailipv6AS"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/mailAS.dot" -o $FOLDER/results/"mailAS6"-sfdp.svg

rm "$FOLDER/mailcountry.tmp"
rm "$FOLDER/mxip.tmp"
rm "$FOLDER/mx.tmp"
rm "$FOLDER/mailAS.tmp"

printf "Done\n"
exit 0
