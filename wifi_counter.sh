#!/bin/bash
# This script will run nmap to determine neighbors on the same wifi as the specified interface.

# Specify the interface you want to count beans on
interface=wlan0

# Add any mac addresses you want to exclude here separated by a space
excludes="F0:9F:C2:C4:04:9A"

## Do not modify below this line

# Source in our database info from a super secret file
. ~/db_creds.txt

gather_stats () {
  # Zero out the count
  count=0
 
  # Determine the subnet of the wireless interface
  subnet=$(ip route | grep $interface | grep -v default | awk '{print $1}')
  
  # Get the list of mac addresses on the wifi 
  macs=$(sudo nmap -sn -e wlan0 192.168.145.0/24 | grep ^MAC | awk '{print $3}')
  for mac in $macs
   do
    # If this mac is in the exclusion list skip it, otherwise up the count and update the influxdb w/ the mac
    if [[ "$excludes" =~ "$mac" ]]
     then
      continue
     else
       count=$((count+1))
       # update todays log file 
       echo "${mac}" >> /home/pi/wifi_counter/logs/$(date +%Y-%m-%d).log
     fi
  done

  # Update the influxdb with the count
  curl -s -u $INFLUXDB_USERNAME:$INFLUXDB_PASSWORD -XPOST "http://$INFLUXDB_HOST:$INFLUXDB_PORT/write?db=$INFLUXDB_DATABASE" --data-binary "mac_count value=${count}"
}

daily_total () {
  # Get yesterdays date
  yesterday=$(date -d "-1 day" +%Y-%m-%d)
  if [[ -f /home/pi/wifi_counter/logs/${yesterday}.log ]]
   then
    yesterdays_total=$(cat /home/pi/wifi_counter/logs/${yesterday}.log | sort -u | wc -l)
    curl -s -u $INFLUXDB_USERNAME:$INFLUXDB_PASSWORD -XPOST "http://$INFLUXDB_HOST:$INFLUXDB_PORT/write?db=$INFLUXDB_DATABASE" --data-binary "daily_total value=${yesterdays_total}"
  fi  
  
}
case $1 in 
 gather_stats) 
   gather_stats
   ;;
 daily_total)
   daily_total
   ;;
esac

