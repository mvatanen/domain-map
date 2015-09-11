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
 echo "\"$line\" -> "\"$ip\" >> "$FOLDER/dot/www6.dot"
 echo "$line,$ip" >> "$FOLDER/results/www6.csv"
 echo "$line,$ip" >> "$FOLDER/results/mysql/www-ipv6-mysql.csv"
 done
done < domains

#Country
while read line
do
 for ip in `cat "$FOLDER/$line"`
 do
 for country in "`geoiplookup $ip|grep Country|cut -d ',' -f2-|awk {'print tolower($0)'}|tr -d "'"|xargs`"
 do
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/dot/wwwcountry.dot"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/dot/wwwAS.dot"
 echo "$line,$AS" >> "$FOLDER/results/www6AS.csv"
 echo "$line,$ip,$AS" >> "$FOLDER/results/mysql/www-ipv6-as-mysql.csv"
 done
 done
done < domains

#Generate dor files
#ASNUMBER
cat "$FOLDER/dot/wwwAS.dot"|sort|uniq >> "$FOLDER/dot/wwwAS.tmp"
rm "$FOLDER/dot/wwwAS.dot"
echo "digraph wwwipv6as {" > "$FOLDER/dot/wwwAS.dot"
cat "$FOLDER/dot/wwwAS.tmp" >> "$FOLDER/dot/wwwAS.dot"
echo "}" >> "$FOLDER/dot/wwwAS.dot"

#COUNTRY
cat "$FOLDER/dot/wwwcountry.dot"|sort|uniq >> "$FOLDER/dot/wwwcountry.tmp"
rm "$FOLDER/dot/wwwcountry.dot"
echo "digraph wwwipv6country {" > "$FOLDER/dot/wwwcountry.dot"
cat "$FOLDER/dot/wwwcountry.tmp" >> "$FOLDER/dot/wwwcountry.dot"
echo "}" >> "$FOLDER/dot/wwwcountry.dot"

#IPV6
cat "$FOLDER/dot/www6.dot"|sort|uniq >> "$FOLDER/dot/www6.tmp"
rm "$FOLDER/dot/www6.dot"
echo "digraph wwwipv6 {" > "$FOLDER/dot/www6.dot"
cat "$FOLDER/dot/www6.tmp" >> "$FOLDER/dot/www6.dot"
echo "}" >> "$FOLDER/dot/www6.dot"

echo "Generating pictures..."
DOT=/usr/bin/dot

#WWW6
$DOT -Tsvg -Kfdp "$FOLDER/dot/www6.dot" -o $FOLDER/results/"www6"-fdp.svg
#$DOT -Tsvg -Kdot "$FOLDER/dot/www6.dot" -o $FOLDER/results/"www6"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/www6.dot" -o $FOLDER/results/"www6"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/www6.dot" -o $FOLDER/results/"www6"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/www6.dot" -o $FOLDER/results/"www6"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/www6.dot" -o $FOLDER/results/"www6"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry6"-sfdp.svg

#ASNUMBER
$DOT -Tsvg -Kfdp $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS6"-sfdp.svg


rm $FOLDER/dot/"www6.tmp"
rm $FOLDER/dot/"wwwcountry.tmp"
rm $FOLDER/dot/"wwwAS.tmp"

printf "Done\n"
exit 0
