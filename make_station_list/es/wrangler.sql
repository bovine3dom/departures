-- duckdb

-- [cn]-stations.csv: country, name, url, lon, lat
copy (
    select country, name,
    concat('https://pantallas-estaciones.vercel.app/~/?station=', (uic::string)[3:-1]) as url,
    longitude as lon, latitude as lat
    from '../stations.csv'
    where country = 'ES' and uic is not null
    and (uic::string)[1:2] == '71'
) to 'es-stations.csv' (header false);
-- https://pantallas-estaciones.vercel.app/~/?station=71801
