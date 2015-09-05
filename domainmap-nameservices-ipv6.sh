#!/bin/bash


echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/nsip6
FOLDER=$cur/$PROJECT/nsip6
mkdir $FOLDER/ip
mkdir -p $FOLDER/results/mysql

#DNS Ns-records ipv6
while read line; do dig NS +tries=5 $(idn2 $line) +short|awk {'print tolower($1)'}>>$FOLDER/$line;sleep 0.2;done <domains

#IP
while read line
do
 for servername in `cat "$FOLDER/$line"`
 do
 if !
 dig AAAA +tries=5 $(idn2 $servername) +short|grep -v $line >/dev/null
 then
 for serverip in `dig AAAA $servername +short|awk {'print tolower($1)'}`
 do
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/nsip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/ns.dot"
 echo "$line,$serverip" >> "$FOLDER/results/nsip6.csv"
 echo "$line,$servername" >> "$FOLDER/results/ns6.csv"
 echo "$line,$servername,$serverip" >> "$FOLDER/results/mysql/name-server-ip6-mysql.csv"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/namecountry.dot"
 echo "$line,$country" >> "$FOLDER/results/namecountry6.csv"
 echo "$line,$serverip,$country" >> "$FOLDER/results/mysql/name-ip6-country-mysql.csv"
 done
 done
done < domains

#AS
while read line
do
 for serverip in `cat "$FOLDER/ip/$line"`
 do
 for AS in "`geoiplookup $serverip|grep ASNum|cut -d ':' -f2-|awk {'print tolower($0)'}|tr -d "'"|xargs`"
 do
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/nameAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/nameAS6.csv"
 echo "$line,$serverip,$AS" >> "$FOLDER/results/mysql/name-ip6-as-mysql.csv"
 done
 done
done < domains

#Make dot files
cat "$FOLDER/nameAS.dot"|sort|uniq >> "$FOLDER/nameAS.tmp"
rm "$FOLDER/nameAS.dot"
echo "digraph nsipv6AS {" > "$FOLDER/nameAS.dot"
cat "$FOLDER/nameAS.tmp" >> "$FOLDER/nameAS.dot"
echo "}" >> "$FOLDER/nameAS.dot"

cat "$FOLDER/ns.dot"|sort|uniq >> "$FOLDER/ns.tmp"
rm "$FOLDER/ns.dot"
echo "digraph nsipv6resolvers {" > "$FOLDER/ns.dot"
cat "$FOLDER/ns.tmp" >> "$FOLDER/ns.dot"
echo "}" >> "$FOLDER/ns.dot"

cat "$FOLDER/namecountry.dot"|sort|uniq >> "$FOLDER/namecountry.tmp"
rm "$FOLDER/namecountry.dot"
echo "digraph nsipv6country {" > "$FOLDER/namecountry.dot"
cat "$FOLDER/namecountry.tmp" >> "$FOLDER/namecountry.dot"
echo "}" >> "$FOLDER/namecountry.dot"

cat "$FOLDER/nsip.dot"|sort|uniq >> "$FOLDER/nsip.tmp"
rm "$FOLDER/nsip.dot"
echo "digraph nsipv6 {" > "$FOLDER/nsip.dot"
cat "$FOLDER/nsip.tmp" >> "$FOLDER/nsip.dot"
echo "}" >> "$FOLDER/nsip.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#nameservers
$DOT -Tsvg -Kfdp "$FOLDER/ns.dot" -o $FOLDER/results/"ns6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/ns.dot" -o $FOLDER/results/"ns6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/ns.dot" -o $FOLDER/results/"ns6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/ns.dot" -o $FOLDER/results/"ns6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/ns.dot" -o $FOLDER/results/"ns6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/ns.dot" -o $FOLDER/results/"ns6"-sfdp.svg

#IP
$DOT -Tsvg -Kfdp "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/nsip.dot" -o $FOLDER/results/"nsip6"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/namecountry.dot" -o $FOLDER/results/"namecountry6"-sfdp.svg

#AS
$DOT -Tsvg -Kfdp "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS6"-sfdp.svg


rm "$FOLDER/nsip.tmp"
rm "$FOLDER/namecountry.tmp"
rm "$FOLDER/nameAS.tmp"

printf "Done\n"
exit 0
