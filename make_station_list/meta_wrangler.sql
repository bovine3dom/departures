-- clickhouse
-- kontur population grid left as exercise for the reader
select c1 country, c2 name, c3 url, c4 lon, c5 lat, geoToH3(lat, lon, 8) h3, p.population
from file('chungus/friendly_stations.csv') fs
left join public_kontur_population_20231101 p on p.h3 = h3
order by name asc
into outfile 'friendly_stations_with_pop.csv' truncate format CSVWithNames; -- always a surprise: goes in working dir

-- this needs loads of memory and is it really better?
 --left join (
 --    select arrayJoin(h3kRing(h3, 2)) h3_t, sum(population) population from public_kontur_population_20231101
 --    group by h3_t
 --) p
