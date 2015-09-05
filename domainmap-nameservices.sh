
#https://github.com/mvatanen

#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/nsip
FOLDER=$cur/$PROJECT/nsip
mkdir $FOLDER/ip
mkdir -p $FOLDER/results/mysql

#DNS NS-records
while read line; do dig NS +tries=5 $(idn2 $line) +short|awk {'print tolower($1)'}>>$FOLDER/$line;sleep 0.2;done <domains

#Nameserver IP
while read line
do
 for servername in `cat "$FOLDER/$line"`
 do
 for serverip in `dig $servername +short|awk {'print tolower($1)'}`
 do
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/nsip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/ns.dot"
 echo "$line,$serverip" >> "$FOLDER/results/nsip.csv"
 echo "$line,$servername" >> "$FOLDER/results/ns.csv"
 echo "$line,$servername,$serverip" >> "$FOLDER/results/mysql/name-server-ip-mysql.csv"
 echo $serverip >> "$FOLDER/ip/$line"
 done
 done
done < domains

#IP24
while read line
do
 for servername in `cat "$FOLDER/$line"`
 do
 for serverip in `dig $servername +short|sed 's/\.[0-9]*$/.0/'|awk {'print tolower($1)'}`
 do
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/nsip24.dot"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/namecountry.dot"
 echo "$line,$country" >> "$FOLDER/results/nscountry.csv"
 echo "$line,$serverip,$country" >> "$FOLDER/results/mysql/name-ip-country-mysql.csv"
 done
 done
done < domains

#AS
while read line
do
 for ip in `cat "$FOLDER/ip/$line"` 
 do
 for AS in "`geoiplookup $ip|grep ASNum|cut -d ':' -f2-|awk {'print tolower($0)'}|tr -d "'"|xargs`"
 do
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/nameAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/nsAS.csv"
 echo "$line,$ip,$AS" >> "$FOLDER/results/mysql/name-ip-as-mysql.csv"
 done
 done
done < domains

#Make dot files
cat "$FOLDER/nameAS.dot"|sort|uniq >> "$FOLDER/nameAS.tmp"
rm "$FOLDER/nameAS.dot"
echo "digraph nsAS {" > "$FOLDER/nameAS.dot"
cat "$FOLDER/nameAS.tmp" >> "$FOLDER/nameAS.dot"
echo "}" >> "$FOLDER/nameAS.dot"

cat "$FOLDER/ns.dot"|sort|uniq >> "$FOLDER/ns.tmp"
rm "$FOLDER/ns.dot"
echo "digraph nsresolvers {" > "$FOLDER/ns.dot"
cat "$FOLDER/ns.tmp" >> "$FOLDER/ns.dot"
echo "}" >> "$FOLDER/ns.dot"

cat "$FOLDER/namecountry.dot"|sort|uniq >> "$FOLDER/namecountry.tmp"
rm "$FOLDER/namecountry.dot"
echo "digraph nameservercountry {" > "$FOLDER/namecountry.dot"
cat "$FOLDER/namecountry.tmp" >> "$FOLDER/namecountry.dot"
echo "}" >> "$FOLDER/namecountry.dot"

cat "$FOLDER/nsip.dot"|sort|uniq >> "$FOLDER/nsip.tmp"
rm "$FOLDER/nsip.dot"
echo "digraph nsIP {" > "$FOLDER/nsip.dot"
cat "$FOLDER/nsip.tmp" >> "$FOLDER/nsip.dot"
echo "}" >> "$FOLDER/nsip.dot"

cat "$FOLDER/nsip24.dot"|sort|uniq >> "$FOLDER/nsip24.tmp"
rm "$FOLDER/nsip24.dot"
echo "digraph nsIP24 {" > "$FOLDER/nsip24.dot"
cat "$FOLDER/nsip24.tmp" >> "$FOLDER/nsip24.dot"
echo "}" >> "$FOLDER/nsip24.dot"


echo "Generating pictures..."
DOT=/usr/bin/dot

#nameservers
$DOT -Tsvg -Kfdp "$FOLDER/ns.dot" -o $FOLDER/results/"ns"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/ns.dot" -o $FOLDER/results/"ns"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/ns.dot" -o $FOLDER/results/"ns"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/ns.dot" -o $FOLDER/results/"ns"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/ns.dot" -o $FOLDER/results/"ns"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/ns.dot" -o $FOLDER/results/"ns"-sfdp.svg

#IP
$DOT -Tsvg -Kfdp "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip"-fdp.svg
$DOT -Tsvg -Kfdp "$FOLDER/nsip24.dot" -o $FOLDER/results/"nsip24"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry"-sfdp.svg

#AS
$DOT -Tsvg -Kfdp "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS"-sfdp.svg


rm "$FOLDER/nsip.tmp"
rm "$FOLDER/nsip24.tmp"
rm "$FOLDER/namecountry.tmp"
rm "$FOLDER/nameAS.tmp"

printf "Done\n"
exit 0
