-- clickhouse
-- kontur population grid left as exercise for the reader
select * except h3 from (
    --select c1 country, c2 name, c3 url, c4 lon, c5 lat, geoToH3(lat, lon, 8) h3, p.population
    select name, url, round(max(crow_km)) longest_route_km from (
        select concat(c2, ', ', c1) name, c3 url, if(c4 is null, null, arrayJoin(h3kRing(geoToH3(assumeNotNull(c5), assumeNotNull(c4), 10), 2))) h3
        from file('chungus/friendly_stations.csv') fs
    ) stations
    left join (
        select crow_km, geoToH3(stop_lat, stop_lon, 10) h3
        from transitous_everything_20260218_stop_statistics_unmerged3
        -- only trains (we had loads of coaches before lol)
        where route_type = 2 or route_type between 100 and 117
    ) stats using h3
    group by name, url
    order by name asc, longest_route_km desc
)
into outfile 'friendly_stations_with_distance.json' truncate format JSONEachRow -- always a surprise: goes in working dir
settings output_format_json_array_of_rows=1;
