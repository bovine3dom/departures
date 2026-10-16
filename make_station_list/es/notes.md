# Stations

Copy the JSON output from datagrabber's `adif_station_catalogue` command to
`adif-stations.json`. Put [Trainline's stations.csv](https://raw.githubusercontent.com/trainline-eu/stations/master/stations.csv)
in `../stations.csv`. Then run `duckdb < wrangler.sql` from this directory.
