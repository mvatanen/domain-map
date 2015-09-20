#https://github.com/mvatanen


#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/mxip6
FOLDER=$cur/$PROJECT/mxip6
mkdir $FOLDER/ip
mkdir -p $FOLDER/results/mysql
mkdir -p $FOLDER/results/dot


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
 echo "\"$line\" -> "\"$serverip\" >> "$FOLDER/results/dot/mx6.dot"
 echo "\"$line\" -> "\"$servername\" >> "$FOLDER/results/dot/mxipv6.dot"
 echo "$line,$serverip" >> "$FOLDER/results/mxipv6.csv"
 echo "$line,$servername" >> "$FOLDER/results/mxipv6.csv"
 echo "$line,$servername,$serverip" >> "$FOLDER/results/mysql/mail-server-ip6-mysql.csv"
 echo $serverip >> "$FOLDER/ip/$line"
 done
 fi
 done
done < domains

 #FIND MORE DOMAINS (PTR)
while read line
do
 for ip in `cat "$FOLDER/ip/$line"`
 do
 dig +noall +answer -x $ip|awk {'print tolower($5)'} >> $FOLDER/results/PTR_Domains.txt
 done
done < domains

#Country
while read line
do
 for serverip in `cat "$FOLDER/ip/$line"`
 do
 for country in "`geoiplookup $serverip|grep Country|cut -d ',' -f2-|tr -d "'"|xargs`"
 do
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/results/dot/mailcountryipv6.dot"
 echo "$line,$country" >> "$FOLDER/results/mailcountryipv6.csv"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/results/dot/mailipv6AS.dot"
 echo "$line,$AS" >> "$FOLDER/results/mailipv6AS.csv"
 echo "$line,$server,$AS" >> "$FOLDER/results/mysql/mail-ip6-as-mysql.csv"
 done
 done
done < domains

#Make dot files
cat "$FOLDER/results/dot/mailipv6AS.dot"|sort|uniq >> "$FOLDER/results/dot/mailipv6AS.tmp"
rm "$FOLDER/results/dot/mailipv6AS.dot"
echo "digraph mailserversipv6AS {" > "$FOLDER/results/dot/mailipv6AS.dot"
cat "$FOLDER/results/dot/mailipv6AS.tmp" >> "$FOLDER/results/dot/mailipv6AS.dot"
echo "}" >> "$FOLDER/results/dot/mailipv6AS.dot"

cat "$FOLDER/results/dot/mxipv6.dot"|sort|uniq >> "$FOLDER/results/dot/mxipv6.tmp"
rm "$FOLDER/results/dot/mxipv6.dot"
echo "digraph mailserversipv6 {" > "$FOLDER/results/dot/mxipv6.dot"
cat "$FOLDER/results/dot/mxipv6.tmp" >> "$FOLDER/results/dot/mxipv6.dot"
echo "}" >> "$FOLDER/results/dot/mxipv6.dot"

cat "$FOLDER/results/dot/mailcountryipv6.dot"|sort|uniq >> "$FOLDER/results/dot/mailcountryipv6.tmp"
rm "$FOLDER/results/dot/mailcountryipv6.dot"
echo "digraph mailipv6country {" > "$FOLDER/results/dot/mailcountryipv6.dot"
cat "$FOLDER/results/dot/mailcountryipv6.tmp" >> "$FOLDER/results/dot/mailcountryipv6.dot"
echo "}" >> "$FOLDER/results/dot/mailcountryipv6.dot"

cat "$FOLDER/results/dot/mx6.dot"|sort|uniq >> "$FOLDER/results/dot/mx6.tmp"
rm "$FOLDER/results/dot/mx6.dot"
echo "digraph mailmx6 {" > "$FOLDER/results/dot/mx6.dot"
cat "$FOLDER/results/dot/mx6.tmp" >> "$FOLDER/results/dot/mx6.dot"
echo "}" >> "$FOLDER/results/dot/mx6.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#SERVERS

$DOT -Tsvg -Kfdp "$FOLDER/results/dot/mx6.dot" -o $FOLDER/results/"mailserversipv6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/mx6.dot" -o $FOLDER/results/"mx6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/mx6.dot" -o $FOLDER/results/"mx6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/mx6.dot" -o $FOLDER/results/"mx6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/mx6.dot" -o $FOLDER/results/"mx6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/mx6.dot" -o $FOLDER/results/"mx6"-sfdp.svg

#IP6
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/mxipv6.dot" -o $FOLDER/results/"mxipv6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/mxipv6.dot" -o $FOLDER/results/"mxip6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/mxipv6.dot" -o $FOLDER/results/"mxip6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/mxipv6.dot" -o $FOLDER/results/"mxip6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/mxipv6.dot" -o $FOLDER/results/"mxip6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/mxipv6.dot" -o $FOLDER/results/"mxip6"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/mailcountryipv6.dot" -o $FOLDER/results/"mailcountryipv6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/emailcountryipv6.dot" -o $FOLDER/results/"mailcountry6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/emailcountryipv6.dot" -o $FOLDER/results/"mailcountry6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/emailcountryipv6.dot" -o $FOLDER/results/"mailcountry6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/emailcountryipv6.dot" -o $FOLDER/results/"mailcountry6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/emailcountryipv6.dot" -o $FOLDER/results/"mailcountry6"-sfdp.svg


#AS
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/mailipv6AS.dot" -o $FOLDER/results/"mailipv6AS"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/mailipv6AS.dot" -o $FOLDER/results/"mailipv6AS"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/mailipv6AS.dot" -o $FOLDER/results/"mailipv6AS6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/mailipv6AS.dot" -o $FOLDER/results/"mailipv6AS6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/mailipv6AS.dot" -o $FOLDER/results/"mailipv6AS6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/mailipv6AS.dot" -o $FOLDER/results/"mailipv6AS6"-sfdp.svg

rm "$FOLDER/results/dot/mailcountryipv6.tmp"
rm "$FOLDER/results/dot/mxipv6.tmp"
rm "$FOLDER/results/dot/mx6.tmp"
rm "$FOLDER/results/dot/mailipv6AS.tmp"

printf "Done\n"
exit 0
