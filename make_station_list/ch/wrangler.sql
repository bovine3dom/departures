-- clickhouse-local (duckdb gets sad)
-- select * from '554d4d8a-3720-453d-8571-727e0a0a7097.csv' limit 1;

-- [cn]-stations.csv: country, name, url, lon, lat
select isoCountryCode country, 
designationOfficial name,
concat('https://mesdeparts.ch/?station=', replace(sloid, ':', '-')) as url,
wgs84East lon, wgs84North lat,
number uic
from '554d4d8a-3720-453d-8571-727e0a0a7097.csv'
into outfile 'ch-stations.csv' truncate
-- https://pantallas-estaciones.vercel.app/~/?station=71801
-- https://mesdeparts.ch/classic/?station=Parent8505307

-- annoyingly trainline is missing lots of UIC for stations

-- https://data.opentransportdata.swiss/dataset/service-point-v2/resource/554d4d8a-3720-453d-8571-727e0a0a7097
-- can filter for TRAIN and 85
