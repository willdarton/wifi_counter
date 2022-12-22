#!/bin/bash
# This script will run nmap to determine neighbors on the same wifi as the specified interface.

# Source in our database info from a super secret file
. ~/db_creds.txt

# Specify the interface you want to count beans on
interface=wlan0

# Add any mac addresses you want to exclude here separated by a space
excludes="F0:9F:C2:C4:04:9A"

# Zero out the count
count=0

# Determine the subnet of the wireless interface
subnet=$(ip route | grep $interface | grep -v default | awk '{print $1}')

# Get the list of mac addresses on the wifi 
macs=$(sudo nmap -sn -e wlan0 192.168.145.0/24 | grep ^MAC | awk '{print $3}')
for mac in $macs
 do
  if [[ "$excludes" =~ "$mac" ]]
   then
    continue
   else
     count=$((count+1))
   fi
done

# Update the influxdb with the count
curl -s -u $INFLUXDB_USERNAME:$INFLUXDB_PASSWORD -XPOST "http://$INFLUXDB_HOST:$INFLUXDB_PORT/write?db=$INFLUXDB_DATABASE" --data-binary "mac_count value=${count}"
