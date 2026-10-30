-- duckdb

-- [cn]-stations.csv: country, name, url, lon, lat
copy (
    select country, name,
    concat('https://www.b-europe.com/EN/Real-time?station=', (name)) as url,
    longitude as lon, latitude as lat, uic
    from '../stations.csv'
    where country = 'BE' and uic is not null
) to 'be-stations.csv' (header false);
-- needs On Voie Tous running because, lol, sncb doesn't believe in deep links
