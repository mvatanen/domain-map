#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/www/results/mysql
FOLDER=$cur/$PROJECT/www

#DNS A-records
while read line
do
if dig A +tries=5 $(idn2 $line)|grep NXDOMAIN >/dev/null
 then
 dig A +tries=5 $(idn2 www.$line) +short|awk {'print tolower($1)'} >> $FOLDER/$line
 else 
 dig A +tries=5 $(idn2 $line) +short|awk {'print tolower($1)'} >> $FOLDER/$line
 fi
sleep 0.2
done < domains

#FIND IP
while read line
do
 for ip in `cat "$FOLDER/$line"`
 do
 echo "\"$line\" -> "\"$ip\" >> "$FOLDER/wwwIP.dot"
 echo "$line,$ip" >> "$FOLDER/results/wwwIP.csv"
 echo "$line,$ip" >> "$FOLDER/results/mysql/www-ip-mysql.csv"
 done
done < domains

#IP-SUBNET /24
while read line
do
 for server in `cat "$FOLDER/$line" | sed 's/\.[0-9]*$/.0/'`
 do
 echo "\"$line\" -> "\"$server\" >> "$FOLDER/wwwIP24.dot"
 echo "$line,A,$server" >> "$FOLDER/results/wwwIP24.csv"
 done
done < domains


#Country
while read line
do
 for ip in `cat "$FOLDER/$line"`
 do
 for country in "`geoiplookup $ip|grep Country|cut -d ',' -f2-|awk {'print tolower($0)'}|tr -d "'"|xargs`"
 do
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/wwwcountry.dot"
 echo "$line,$country" >> "$FOLDER/results/wwwcountry.csv"
 echo "$line,$ip,$country" >> "$FOLDER/results/mysql/www-ip-country-mysql.csv"
 done
 done
done < domains

#AS NUMBER
while read line
do
 for ip in `cat "$FOLDER/$line"`
 do
 for AS in "`geoiplookup $ip|grep ASNum|cut -d ':' -f2-|awk {'print tolower($0)'}|tr -d "'"|xargs`"
 do
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/wwwAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/wwwAS.csv"
 echo "$line,$ip,$AS" >> "$FOLDER/results/mysql/www-ip-as-mysql.csv"
 done
 done
done < domains

#MAKE DOT FILES
cat "$FOLDER/wwwAS.dot"|sort|uniq >> "$FOLDER/wwwAS.tmp"
rm "$FOLDER/wwwAS.dot"
echo "digraph wwwAS {" > "$FOLDER/wwwAS.dot"
cat "$FOLDER/wwwAS.tmp" >> "$FOLDER/wwwAS.dot"
echo "}" >> "$FOLDER/wwwAS.dot"

cat "$FOLDER/wwwcountry.dot"|sort|uniq >> "$FOLDER/wwwcountry.tmp"
rm "$FOLDER/wwwcountry.dot"
echo "digraph wwwcountry {" > "$FOLDER/wwwcountry.dot"
cat "$FOLDER/wwwcountry.tmp" >> "$FOLDER/wwwcountry.dot"
echo "}" >> "$FOLDER/wwwcountry.dot"

cat "$FOLDER/wwwIP.dot"|sort|uniq >> "$FOLDER/wwwIP.tmp"
rm "$FOLDER/wwwIP.dot"
echo "digraph wwwIP {" > "$FOLDER/wwwIP.dot"
cat "$FOLDER/wwwIP.tmp" >> "$FOLDER/wwwIP.dot"
echo "}" >> "$FOLDER/wwwIP.dot"

cat "$FOLDER/wwwIP24.dot"|sort|uniq >> "$FOLDER/wwwIP24.tmp"
rm "$FOLDER/wwwIP24.dot"
echo "digraph wwwIP24 {" > "$FOLDER/wwwIP24.dot"
cat "$FOLDER/wwwIP24.tmp" >> "$FOLDER/wwwIP24.dot"
echo "}" >> "$FOLDER/wwwIP24.dot"


echo "Generating pictures..."
DOT=/usr/bin/dot

#WWWIP
$DOT -Tsvg -Kfdp "$FOLDER/wwwIP.dot" -o $FOLDER/results/"wwwIP"-fdp.svg
$DOT -Tsvg -Kfdp "$FOLDER/wwwIP24.dot" -o $FOLDER/results/"wwwIP24"-fdp.svg

#$DOT -Tsvg -Kdot "$FOLDER/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp $FOLDER/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-sfdp.svg

#ASNUMBER
$DOT -Tsvg -Kfdp $FOLDER/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-sfdp.svg


rm $FOLDER/"wwwIP.tmp"
rm $FOLDER/"wwwIP24.tmp"
rm $FOLDER/"wwwcountry.tmp"
rm $FOLDER/"wwwAS.tmp"

printf "Done\n"
exit 0
