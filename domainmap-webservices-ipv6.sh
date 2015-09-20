#https://github.com/mvatanen

#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/wwwipv6/results/mysql
mkdir -p $cur/$PROJECT/wwwipv6/results/dot
FOLDER=$cur/$PROJECT/wwwipv6

#DNS A-records
while read line
do
 if ! 
 dig AAAA +tries=5 $(idn2 $line) +short|grep -v $line >/dev/null
 then
 dig AAAA +tries=5 $(idn2 $line) +short|awk {'print tolower($1)'} >> $FOLDER/$line
 fi 
 if !
 dig AAAA +tries=5 $(idn2 www.$line) +short|grep -v $line >/dev/null
 then
 dig AAAA +tries=5 $(idn2 www.$line) +short|awk {'print tolower($1)'} >> $FOLDER/$line
 fi
sleep 0.2
done < domains

#IP
while read line
do
 for ip in `cat "$FOLDER/$line"`
 do
 echo "\"$line\" -> "\"$ip\" >> "$FOLDER/results/dot/www6.dot"
 echo "$line,$ip" >> "$FOLDER/results/www6.csv"
 echo "$line,$ip" >> "$FOLDER/results/mysql/www-ipv6-mysql.csv"
 done
done < domains

#FIND MORE DOMAINS (PTR)
while read line
do
 for ip in `cat "$FOLDER/$line"`
 do
 dig +noall +answer -x $ip|awk {'print tolower($5)'} >> $FOLDER/results/PTR_Domains_www_IPv6.txt
 done
done < domains



#Country
while read line
do
 for ip in `cat "$FOLDER/$line"`
 do
 for country in "`geoiplookup $ip|grep Country|cut -d ',' -f2-|awk {'print tolower($0)'}|tr -d "'"|xargs`"
 do
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/results/dot/wwwcountry.dot"
 echo "$line,$country" >> "$FOLDER/results/www6country.csv"
 echo "$line,$ip,$country" >> "$FOLDER/results/mysql/www-ipv6-country-mysql.csv"
 done
 done
done < domains

#AS
while read line
do
 for ip in `cat "$FOLDER/$line"` 
 do
 for AS in "`geoiplookup $ip|grep ASNum|cut -d ':' -f2-|awk {'print tolower($0)'}|tr -d "'"|xargs`"
 do
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/results/dot/wwwAS.dot"
 echo "$line,$AS" >> "$FOLDER/results/www6AS.csv"
 echo "$line,$ip,$AS" >> "$FOLDER/results/mysql/www-ipv6-as-mysql.csv"
 done
 done
done < domains

#Generate dor files
#ASNUMBER
cat "$FOLDER/results/dot/wwwAS.dot"|sort|uniq >> "$FOLDER/results/dot/wwwAS.tmp"
rm "$FOLDER/results/dot/wwwAS.dot"
echo "digraph wwwipv6as {" > "$FOLDER/results/dot/wwwAS.dot"
cat "$FOLDER/results/dot/wwwAS.tmp" >> "$FOLDER/results/dot/wwwAS.dot"
echo "}" >> "$FOLDER/results/dot/wwwAS.dot"

#COUNTRY
cat "$FOLDER/results/dot/wwwcountry.dot"|sort|uniq >> "$FOLDER/results/dot/wwwcountry.tmp"
rm "$FOLDER/results/dot/wwwcountry.dot"
echo "digraph wwwipv6country {" > "$FOLDER/results/dot/wwwcountry.dot"
cat "$FOLDER/results/dot/wwwcountry.tmp" >> "$FOLDER/results/dot/wwwcountry.dot"
echo "}" >> "$FOLDER/results/dot/wwwcountry.dot"

#IPV6
cat "$FOLDER/results/dot/www6.dot"|sort|uniq >> "$FOLDER/results/dot/www6.tmp"
rm "$FOLDER/results/dot/www6.dot"
echo "digraph wwwipv6 {" > "$FOLDER/results/dot/www6.dot"
cat "$FOLDER/results/dot/www6.tmp" >> "$FOLDER/results/dot/www6.dot"
echo "}" >> "$FOLDER/results/dot/www6.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#WWW6
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/www6.dot" -o $FOLDER/results/"www6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/results/dot/www6.dot" -o $FOLDER/results/"www6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/www6.dot" -o $FOLDER/results/"www6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/www6.dot" -o $FOLDER/results/"www6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/www6.dot" -o $FOLDER/results/"www6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/www6.dot" -o $FOLDER/results/"www6"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-sfdp.svg

#ASNUMBER
$DOT -Tsvg -Kfdp $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-sfdp.svg


rm $FOLDER/results/dot/"www6.tmp"
rm $FOLDER/results/dot/"wwwcountry.tmp"
rm $FOLDER/results/dot/"wwwAS.tmp"

printf "Done\n"
exit 0
