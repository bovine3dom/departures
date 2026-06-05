#!/bin/fish
cat */*-stations.csv | qsv fixlengths -l8 | ssh vauban 'cat - > /mnt/chungus/clickhouse_files/friendly_stations.csv' # nb change if you need to change length
ssh vauban

# ... do your clickhouse stuff

scp vauban:friendly_stations_with_distance.json .
