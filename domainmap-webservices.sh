#https://github.com/mvatanen

#!/bin/bash

echo -n "Project name: "
read PROJECT
cur=`pwd`
mkdir -p $cur/$PROJECT/www/results/mysql
mkdir -p $cur/$PROJECT/www/results/dot
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
 echo "\"$line\" -> "\"$ip\" >> "$FOLDER/results/dot/wwwIP.dot"
 echo "$line,$ip" >> "$FOLDER/results/wwwIP.csv"
 echo "$line,$ip" >> "$FOLDER/results/mysql/www-ip-mysql.csv"
 done
done < domains

#IP-SUBNET /24
while read line
do
 for server in `cat "$FOLDER/$line" | sed 's/\.[0-9]*$/.0/'`
 do
 echo "\"$line\" -> "\"$server\" >> "$FOLDER/results/dot/wwwIP24.dot"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/results/dot/wwwcountry.dot"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/results/dot/wwwAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/wwwAS.csv"
 echo "$line,$ip,$AS" >> "$FOLDER/results/mysql/www-ip-as-mysql.csv"
 done
 done
done < domains

#MAKE DOT FILES
cat "$FOLDER/results/dot/wwwAS.dot"|sort|uniq >> "$FOLDER/results/dot/wwwAS.tmp"
rm "$FOLDER/results/dot/wwwAS.dot"
echo "digraph wwwAS {" > "$FOLDER/results/dot/wwwAS.dot"
cat "$FOLDER/results/dot/wwwAS.tmp" >> "$FOLDER/results/dot/wwwAS.dot"
echo "}" >> "$FOLDER/results/dot/wwwAS.dot"

cat "$FOLDER/results/dot/wwwcountry.dot"|sort|uniq >> "$FOLDER/results/dot/wwwcountry.tmp"
rm "$FOLDER/results/dot/wwwcountry.dot"
echo "digraph wwwcountry {" > "$FOLDER/results/dot/wwwcountry.dot"
cat "$FOLDER/dot/results/wwwcountry.tmp" >> "$FOLDER/results/dot/wwwcountry.dot"
echo "}" >> "$FOLDER/results/dot/wwwcountry.dot"

cat "$FOLDER/results/dot/wwwIP.dot"|sort|uniq >> "$FOLDER/results/dot/wwwIP.tmp"
rm "$FOLDER/results/dot/wwwIP.dot"
echo "digraph wwwIP {" > "$FOLDER/results/dot/wwwIP.dot"
cat "$FOLDER/results/dot/wwwIP.tmp" >> "$FOLDER/results/dot/wwwIP.dot"
echo "}" >> "$FOLDER/results/dot/wwwIP.dot"

cat "$FOLDER/results/dot/wwwIP24.dot"|sort|uniq >> "$FOLDER/results/dot/wwwIP24.tmp"
rm "$FOLDER/results/dot/wwwIP24.dot"
echo "digraph wwwIP24 {" > "$FOLDER/results/dot/wwwIP24.dot"
cat "$FOLDER/results/dot/wwwIP24.tmp" >> "$FOLDER/results/dot/wwwIP24.dot"
echo "}" >> "$FOLDER/results/dot/wwwIP24.dot"


echo "Generating pictures..."
DOT=/usr/bin/dot

#WWWIP
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP"-fdp.svg
$DOT -Tsvg -Kfdp "$FOLDER/results/dot/wwwIP24.dot" -o $FOLDER/results/"wwwIP24"-fdp.svg

#$DOT -Tsvg -Kdot "$FOLDER/results/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/results/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/results/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/results/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/results/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/results/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-sfdp.svg

#ASNUMBER
$DOT -Tsvg -Kfdp $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/results/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-sfdp.svg


rm $FOLDER/results/dot/"wwwIP.tmp"
rm $FOLDER/results/dot/"wwwIP24.tmp"
rm $FOLDER/results/dot/"wwwcountry.tmp"
rm $FOLDER/results/dot/"wwwAS.tmp"

printf "Done\n"
exit 0
