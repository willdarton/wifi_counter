# Wifi Counter script
This script will query the specified interface and determine the number of IP addresses neighbors.  
The count is then uploaded to an influxdb.  You will need to host and create an influxdb somewhere (or on this pi if you want to run everything locally)

Please create a ~/db_creds.txt file with the following variables
```
INFLUXDB_PORT
INFLUXDB_HOST
INFLUXDB_DATABASE
INFLUXDB_USERNAME
INFLUXDB_PASSWORD
```

# Create two crontab entries as follows
``
*/5 * * * * . $HOME/.bash_profile; /home/pi/wifi_counter/wifi_counter.sh gather_stats
5 0 * * * . $HOME/.bash_profile; /home/pi/wifi_counter/wifi_counter.sh daily_total
```
The first will run every five minutes to collect the current connected MAC addresses
The second will take the previous days unique mac addresses and generate a daily total

In both executions, the data is then uploaded to the influxdb mentioned above.
