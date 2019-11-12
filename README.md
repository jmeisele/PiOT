# PiOT
Self Contained Portable IIoT Stack on Raspberry Pi

# Services Include
- Eclipse Mosquitto
- InfluxDB
- NodeRed
- Grafana

----------------------
# From te command line
- git clone https://github.com/jmeisele/PiOT.git
- cd PiOT
- ./menu.sh
- Choose which services you want to pull Docker images for
    - Portainer (Port 9000)
    - NodeRed (Port 1880)
    - Eclipse Mosquitto
    - InfluxDB (Port 8086)
    - PostGres (Port 5432)
    - Grafana (Port 3000)
- docker-compose up -d
*If influxDB service started, note there is no GUI*
    - docker exec -it influxdb /bin/bash
    - influx (This start's the influxdb shell)
    - show databases
    - create database <NAME_OF_DATABASE>

