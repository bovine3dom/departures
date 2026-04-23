-- duckdb
-- [cn]-stations.csv: country, name, url, lon, lat
--- damn, some of these UIC codes are out of date :(
-- select country, name, concat('https://meine.oebb.at/abfahrtankunft/departure?plc=',uic) url, longitude lon, latitude lat from '../stations.csv' where country = 'AT' and uic is not null;

copy (
    select 'AT' as country, name, concat('https://meine.oebb.at/abfahrtankunft/departure?plc=',uic) url, lon, lat from (
        select d.properties.NAME_SNNB as name,
        concat('810', d.properties.PLC::string) uic,
        d.properties.X_KOORDINATE as lon, d.properties.Y_KOORDINATE as lat from (
            select unnest(features) d from 'GIP_PV_STOPS_EU-DEL-V(1).json'
        )
        where d.properties.PLC > 0
    )
) to 'at-stations.csv' (header false);
