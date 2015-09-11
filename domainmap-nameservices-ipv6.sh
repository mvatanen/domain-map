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
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/dot/nsip.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/dot/ns.dot"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/dot/namecountry.dot"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/dot/nameAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/nameAS6.csv"
 echo "$line,$serverip,$AS" >> "$FOLDER/results/mysql/name-ip6-as-mysql.csv"
 done
 done
done < domains

#Make dot files
cat "$FOLDER/dot/nameAS.dot"|sort|uniq >> "$FOLDER/dot/nameAS.tmp"
rm "$FOLDER/dot/nameAS.dot"
echo "digraph nsipv6AS {" > "$FOLDER/dot/nameAS.dot"
cat "$FOLDER/dot/nameAS.tmp" >> "$FOLDER/dot/nameAS.dot"
echo "}" >> "$FOLDER/dot/nameAS.dot"

cat "$FOLDER/dot/ns.dot"|sort|uniq >> "$FOLDER/dot/ns.tmp"
rm "$FOLDER/dot/ns.dot"
echo "digraph nsipv6resolvers {" > "$FOLDER/dot/ns.dot"
cat "$FOLDER/dot/ns.tmp" >> "$FOLDER/dot/ns.dot"
echo "}" >> "$FOLDER/dot/ns.dot"

cat "$FOLDER/dot/namecountry.dot"|sort|uniq >> "$FOLDER/dot/namecountry.tmp"
rm "$FOLDER/dot/namecountry.dot"
echo "digraph nsipv6country {" > "$FOLDER/dot/namecountry.dot"
cat "$FOLDER/dot/namecountry.tmp" >> "$FOLDER/dot/namecountry.dot"
echo "}" >> "$FOLDER/dot/namecountry.dot"

cat "$FOLDER/dot/nsip.dot"|sort|uniq >> "$FOLDER/dot/nsip.tmp"
rm "$FOLDER/dot/nsip.dot"
echo "digraph nsipv6 {" > "$FOLDER/dot/nsip.dot"
cat "$FOLDER/dot/nsip.tmp" >> "$FOLDER/dot/nsip.dot"
echo "}" >> "$FOLDER/dot/nsip.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#nameservers
$DOT -Tsvg -Kfdp "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/ns.dot" -o $FOLDER/results/"ns6"-sfdp.svg

#IP
$DOT -Tsvg -Kfdp "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/nsip.dot" -o $FOLDER/results/"nsip6"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/namecountry.dot" -o $FOLDER/results/"namecountry6"-sfdp.svg

#AS
$DOT -Tsvg -Kfdp "$FOLDER/nameAS.dot" -o $FOLDER/results/"nameAS6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/nameAS.dot" -o $FOLDER/results/"nameAS6"-sfdp.svg


rm "$FOLDER/dot/nsip.tmp"
rm "$FOLDER/dot/namecountry.tmp"
rm "$FOLDER/dot/nameAS.tmp"

printf "Done\n"
exit 0
