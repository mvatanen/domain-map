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
 echo "\"$line\" -> "\"$ip\" >> "$FOLDER/dot/wwwIP.dot"
 echo "$line,$ip" >> "$FOLDER/results/wwwIP.csv"
 echo "$line,$ip" >> "$FOLDER/results/mysql/www-ip-mysql.csv"
 done
done < domains

#IP-SUBNET /24
while read line
do
 for server in `cat "$FOLDER/$line" | sed 's/\.[0-9]*$/.0/'`
 do
 echo "\"$line\" -> "\"$server\" >> "$FOLDER/dot/wwwIP24.dot"
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
 echo "\"$line\" -> "\"$country\" >> "$FOLDER/dot/wwwcountry.dot"
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
 echo "\"$AS\" -> "\"$line\" >> "$FOLDER/dot/wwwAS.dot"
 echo "$AS,$line" >> "$FOLDER/results/wwwAS.csv"
 echo "$line,$ip,$AS" >> "$FOLDER/results/mysql/www-ip-as-mysql.csv"
 done
 done
done < domains

#MAKE DOT FILES
cat "$FOLDER/dot/wwwAS.dot"|sort|uniq >> "$FOLDER/dot/wwwAS.tmp"
rm "$FOLDER/dot/wwwAS.dot"
echo "digraph wwwAS {" > "$FOLDER/dot/wwwAS.dot"
cat "$FOLDER/dot/wwwAS.tmp" >> "$FOLDER/dot/wwwAS.dot"
echo "}" >> "$FOLDER/wwwAS.dot"

cat "$FOLDER/dot/wwwcountry.dot"|sort|uniq >> "$FOLDER/dot/wwwcountry.tmp"
rm "$FOLDER/dot/wwwcountry.dot"
echo "digraph wwwcountry {" > "$FOLDER/dot/wwwcountry.dot"
cat "$FOLDER/dot/wwwcountry.tmp" >> "$FOLDER/dot/wwwcountry.dot"
echo "}" >> "$FOLDER/dot/wwwcountry.dot"

cat "$FOLDER/dot/wwwIP.dot"|sort|uniq >> "$FOLDER/dot/wwwIP.tmp"
rm "$FOLDER/dot/wwwIP.dot"
echo "digraph wwwIP {" > "$FOLDER/dot/wwwIP.dot"
cat "$FOLDER/dot/wwwIP.tmp" >> "$FOLDER/dot/wwwIP.dot"
echo "}" >> "$FOLDER/dot/wwwIP.dot"

cat "$FOLDER/dot/wwwIP24.dot"|sort|uniq >> "$FOLDER/dot/wwwIP24.tmp"
rm "$FOLDER/dot/wwwIP24.dot"
echo "digraph wwwIP24 {" > "$FOLDER/dot/wwwIP24.dot"
cat "$FOLDER/dot/wwwIP24.tmp" >> "$FOLDER/dot/wwwIP24.dot"
echo "}" >> "$FOLDER/dot/wwwIP24.dot"


echo "Generating pictures..."
DOT=/usr/bin/dot

#WWWIP
$DOT -Tsvg -Kfdp "$FOLDER/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP"-fdp.svg
$DOT -Tsvg -Kfdp "$FOLDER/dot/wwwIP24.dot" -o $FOLDER/results/"wwwIP24"-fdp.svg

#$DOT -Tsvg -Kdot "$FOLDER/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-dot.svg
#$DOT -Tsvg -Kneato "$FOLDER/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-neato.svg
#$DOT -Tsvg -Ktwopi "$FOLDER/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-twopi.svg
#$DOT -Tsvg -Kcirco "$FOLDER/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-circo.svg
#$DOT -Tsvg -Ksfdp "$FOLDER/dot/wwwIP.dot" -o $FOLDER/results/"wwwIP.dot"-sfdp.svg

#COUNTRY
$DOT -Tsvg -Kfdp $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/dot/"wwwcountry.dot" -o $FOLDER/results/"wwwcountry"-sfdp.svg

#ASNUMBER
$DOT -Tsvg -Kfdp $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-fdp.svg
#$DOT -Tsvg -Kdot $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-dot.svg
#$DOT -Tsvg -Kneato $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-neato.svg
#$DOT -Tsvg -Ktwopi $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-twopi.svg
#$DOT -Tsvg -Kcirco $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-circo.svg
#$DOT -Tsvg -Ksfdp $FOLDER/dot/"wwwAS.dot" -o $FOLDER/results/"wwwAS"-sfdp.svg


rm $FOLDER/dot/"wwwIP.tmp"
rm $FOLDER/dot/"wwwIP24.tmp"
rm $FOLDER/dot/"wwwcountry.tmp"
rm $FOLDER/dot/"wwwAS.tmp"

printf "Done\n"
exit 0
