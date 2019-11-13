# PiOT
Self Contained Portable IIoT Stack on Raspberry Pi

# Available Services Include
- Portainer (Docker container management system)
- Eclipse Mosquitto (MQTT Broker)
- InfluxDB (Time series database)
- NodeRed (Browser based for wiring flows together)
- Grafana (Real Time data vizualization)

# From the command line
- git clone https://github.com/jmeisele/PiOT.git
- cd PiOT
- ./menu.sh
# Choose which services you want to pull Docker images for
    - Portainer (Port 9000)
    - NodeRed (Port 1880)
    - Eclipse Mosquitto
    - InfluxDB (Port 8086)
    - PostGres (Port 5432)
    - Grafana (Port 3000)
- docker-compose up -d

*If influxDB service started, note there is no GUI*
- docker exec -it influxdb /bin/bash
- influx (This starts the influxdb shell)

*Some useful influx shell commands*
- show databases
- create database <NAME_OF_DATABASE>

