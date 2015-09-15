#https://github.com/mvatanen

#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/nsip6
FOLDER=$cur/$PROJECT/nsip6
mkdir $FOLDER/ip
mkdir -p $FOLDER/results/mysql
mkdir -p $FOLDER/results/dot

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
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/results/dot/nsip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/results/dot/ns.dot"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/results/dot/namecountry.dot"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/results/dot/nameAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/nameAS6.csv"
 echo "$line,$serverip,$AS" >> "$FOLDER/results/mysql/name-ip6-as-mysql.csv"
 done
 done
done < domains

#Make dot files
cat "$FOLDER/results/dot/nameAS.dot"|sort|uniq >> "$FOLDER/results/dot/nameAS.tmp"
rm "$FOLDER/results/dot/nameAS.dot"
echo "digraph nsipv6AS {" > "$FOLDER/results/dot/nameAS.dot"
cat "$FOLDER/results/dot/nameAS.tmp" >> "$FOLDER/results/dot/nameAS.dot"
echo "}" >> "$FOLDER/results/dot/nameAS.dot"

cat "$FOLDER/results/dot/ns.dot"|sort|uniq >> "$FOLDER/results/dot/ns.tmp"
rm "$FOLDER/results/dot/ns.dot"
echo "digraph nsipv6resolvers {" > "$FOLDER/results/dot/ns.dot"
cat "$FOLDER/results/dot/ns.tmp" >> "$FOLDER/results/dot/ns.dot"
echo "}" >> "$FOLDER/results/dot/ns.dot"

cat "$FOLDER/results/dot/namecountry.dot"|sort|uniq >> "$FOLDER/results/dot/namecountry.tmp"
rm "$FOLDER/results/dot/namecountry.dot"
echo "digraph nsipv6country {" > "$FOLDER/results/dot/namecountry.dot"
cat "$FOLDER/results/dot/namecountry.tmp" >> "$FOLDER/results/dot/namecountry.dot"
echo "}" >> "$FOLDER/results/dot/namecountry.dot"

cat "$FOLDER/results/dot/nsip.dot"|sort|uniq >> "$FOLDER/results/dot/nsip.tmp"
rm "$FOLDER/results/dot/nsip.dot"
echo "digraph nsipv6 {" > "$FOLDER/results/dot/nsip.dot"
cat "$FOLDER/results/dot/nsip.tmp" >> "$FOLDER/results/dot/nsip.dot"
echo "}" >> "$FOLDER/results/dot/nsip.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#nameservers
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/ns.dot" -o $FOLDER/results/"ns6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/ns.dot" -o $FOLDER/results/"ns6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/ns.dot" -o $FOLDER/results/"ns6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/ns.dot" -o $FOLDER/results/"ns6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/ns.dot" -o $FOLDER/results/"ns6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/ns.dot" -o $FOLDER/results/"ns6"-sfdp.svg

#IP
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/nsip.dot" -o $FOLDER/results/"nsip6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/nsip.dot" -o $FOLDER/results/"nsip6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/nsip.dot" -o $FOLDER/results/"nsip6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/nsip.dot" -o $FOLDER/results/"nsip6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/nsip.dot" -o $FOLDER/results/"nsip6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/nsip.dot" -o $FOLDER/results/"nsip6"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-sfdp.svg

#AS
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-sfdp.svg

rm "$FOLDER/results/dot/nsip.tmp"
rm "$FOLDER/results/dot/namecountry.tmp"
rm "$FOLDER/results/dot/nameAS.tmp"

printf "Done\n"
exit 0
