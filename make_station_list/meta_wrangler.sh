#!/bin/fish
cat gb/*-stations.csv | ssh vauban 'cat - > /mnt/chungus/clickhouse_files/friendly_stations.csv'

# ... do your clickhouse stuff

scp vauban:friendly_stations_with_distance.json .
