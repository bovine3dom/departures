-- duckdb
-- REMEMBER: JS SORT AND DUCKDB SORT ARE NOT THE SAME
-- ... i probably could have just done this in clickhouse
-- ... oh but i can't even binary search because i want contains so there's no point
copy (
    --select concat(name, ', ', country) as name, concat(url, if(country='FR', '/horaires#main-content', '')) url, population -- honi soit qui mal y pense
    select concat(name, ', ', country) as name, url, population
    from 'friendly_stations_with_pop.csv'
) to 'friendly_stations_with_pop.json' (array);
