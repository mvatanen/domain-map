
#https://github.com/mvatanen

#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/nsip
FOLDER=$cur/$PROJECT/nsip
mkdir $FOLDER/ip
mkdir -p $FOLDER/results/mysql
mkdir -p $FOLDER/results/dot

#DNS NS-records
while read line; do dig NS +tries=5 $(idn2 $line) +short|awk {'print tolower($1)'}>>$FOLDER/$line;sleep 0.2;done <domains

#Nameserver IP
while read line
do
 for servername in `cat "$FOLDER/$line"`
 do
 for serverip in `dig $servername +short|awk {'print tolower($1)'}`
 do
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/dot/nsip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/dot/ns.dot"
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
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/dot/nsip24.dot"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/dot/namecountry.dot"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/dot/nameAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/nsAS.csv"
 echo "$line,$ip,$AS" >> "$FOLDER/results/mysql/name-ip-as-mysql.csv"
 done
 done
done < domains

#Make dot files
cat "$FOLDER/dot/nameAS.dot"|sort|uniq >> "$FOLDER/dot/nameAS.tmp"
rm "$FOLDER/dot/nameAS.dot"
echo "digraph nsAS {" > "$FOLDER/dot/nameAS.dot"
cat "$FOLDER/dot/nameAS.tmp" >> "$FOLDER/dot/nameAS.dot"
echo "}" >> "$FOLDER/dot/nameAS.dot"

cat "$FOLDER/dot/ns.dot"|sort|uniq >> "$FOLDER/dot/ns.tmp"
rm "$FOLDER/dot/ns.dot"
echo "digraph nsresolvers {" > "$FOLDER/dot/ns.dot"
cat "$FOLDER/dot/ns.tmp" >> "$FOLDER/dot/ns.dot"
echo "}" >> "$FOLDER/dot/ns.dot"

cat "$FOLDER/dot/namecountry.dot"|sort|uniq >> "$FOLDER/dot/namecountry.tmp"
rm "$FOLDER/dot/namecountry.dot"
echo "digraph nameservercountry {" > "$FOLDER/dot/namecountry.dot"
cat "$FOLDER/dot/namecountry.tmp" >> "$FOLDER/dot/namecountry.dot"
echo "}" >> "$FOLDER/dot/namecountry.dot"

cat "$FOLDER/dot/nsip.dot"|sort|uniq >> "$FOLDER/dot/nsip.tmp"
rm "$FOLDER/dot/nsip.dot"
echo "digraph nsIP {" > "$FOLDER/dot/nsip.dot"
cat "$FOLDER/dot/nsip.tmp" >> "$FOLDER/dot/nsip.dot"
echo "}" >> "$FOLDER/nsip.dot"

cat "$FOLDER/dot/nsip24.dot"|sort|uniq >> "$FOLDER/dot/nsip24.tmp"
rm "$FOLDER/dot/nsip24.dot"
echo "digraph nsIP24 {" > "$FOLDER/dot/nsip24.dot"
cat "$FOLDER/dot/nsip24.tmp" >> "$FOLDER/dot/nsip24.dot"
echo "}" >> "$FOLDER/dot/nsip24.dot"


echo "Generating pictures..."
DOT=/usr/bin/dot

#nameservers
$DOT -Tsvg -Kfdp "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns"-sfdp.svg

#IP
$DOT -Tsvg -Kfdp "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip"-fdp.svg
$DOT -Tsvg -Kfdp "$FOLDER/dot/nsip24.dot" -o $FOLDER/results/"nsip24"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry"-sfdp.svg

#AS
$DOT -Tsvg -Kfdp "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS"-sfdp.svg


rm "$FOLDER/dot/nsip.tmp"
rm "$FOLDER/dot/nsip24.tmp"
rm "$FOLDER/dot/namecountry.tmp"
rm "$FOLDER/dot/nameAS.tmp"

printf "Done\n"
exit 0
