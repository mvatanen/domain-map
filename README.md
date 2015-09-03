# domain-map
Shell scripts that finds and visualises relations between domain names and their services


# Description

Provided shell scripts fetch information about domain names / hostnames and their public service information from public dns system and maxmind database.
Data of domains/hostnames and their possibly shared resources is visualised with graphviz/dot and also put to csv files.

Information that scripts collect is:


# A-records

Domain/hostname -> www-server ip addresses

Domain/hostname -> www-server ip addresses, cut to /24 bit subnet mask

Domain/hostname -> www-server ip addresses -> Country

Domain/hostname -> www-server ip addresses -> AS number and service provider

# NS-records

Domain/hostname -> nameserver hostnames

Domain/hostname -> nameserver hostnames -> ip addresses

Domain/hostname -> nameserver hostnames -> ip addresses, cut to /24 bit subnet mask

Domain/hostname -> nameserver hostnames -> ip addresses -> Country

Domain/hostname -> nameserver hostnames -> ip addresses -> AS number and service provider

# MX-records

Domain/hostname -> mailserver hostnames

Domain/hostname -> mailserver hostnames -> ip addresses

Domain/hostname -> mailserver hostnames -> ip addresses, cut to /24 bit subnet mask

Domain/hostname -> mailserver hostnames -> ip addresses -> Country

Domain/hostname -> mailserver hostnames -> ip addresses -> AS number and service provider


So basically scripts do dns queries for A,NS and MX records and resulting ip addresses are queried from maxmind for AS and country information.

IPV4 and IPV6 scripts need to be run separately

All data is saved to project folder.

Processed output goes to "your-project-name"/results folder and it contains:


1.1 csv files for spreadsheet reporting

1.2 *.mysql.csv files for database importing

1.3 svg picture files that are generated from data (best viewed with browser)


Note that *.mysql.csv files have different approach to data than normal csv and aren't necessarily the best option for spreadsheet analysis.


# Requirements

Tested with Xubuntu, Kali-linux and Debian and made for /bin/bash

You need following packages:

dig (dns queries)

idn2 (international names)

geoip-bin geoip-database-contrib (maxmind free database)

graphviz ( (dot) visualisation)

others: awk,sed,cut


# Howto

All scripts take filename "domains" as input. So put your domain and hostnames to that file in the same folder as the scipts. If you want to, you can run all scripts with same project name, since data is put to different folders inside the project folder.

chmod +x scriptname
./scriptname



# Other information

By default, system configured dns addresses are used. You can also modify dig command to use different dns servers.

Default sleep time between queries is 0.2 seconds, so there should be roughly 5 queries / second.

While doing www-server ( A-record) query "domain.name" is first tried and if there is no record then "www.domain.name" is tried next. So if you want to query additional names like mail.domain.com or extranet.domain.com add the names to the domains file.

You can always combine .dot files with other .dot files ( if it  makes any sense), and regenerate pictures

Only one graphviz/dot picture generation format is enabled. Others are commented out (check the end of the scripts). Some formats can't be generated if there are too many objects.

You can also buy more accurate MaxMind database
