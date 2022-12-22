# Wifi Counter script
This script will query the specified interface and determine the number of IP addresses neighbors.  
The count is then uploaded to an influxdb

Please create a ~/db_creds.txt file with the following variables
```
INFLUXDB_PORT
INFLUXDB_HOST
INFLUXDB_DATABASE
INFLUXDB_USERNAME
INFLUXDB_PASSWORD
```
