-- duckdb
-- attempt 3
-- curl --compressed -OJ https://mirror.traines.eu/hafas-ibnr-zhv-gtfs-osm-matching/full.ndjson

-- hmm need to work out how to exclude other countries
-- wget https://raw.githubusercontent.com/isellsoap/deutschlandGeoJSON/main/1_deutschland/4_niedrig.geo.json

install spatial;
load spatial;
copy (
    with germany as (
        select geom from ST_Read('4_niedrig.geo.json')
    )
    select 'DE' country, name, concat('https://bahn.expert/',name) url, location.longitude lon, location.latitude lat from (
        select distinct unnest(station) from 'full.ndjson' 
        where station is not null
    )
    -- only trains
    cross join germany
    where (false
        or products.nationalExpress
        or products.national
        or products.regional
        or products.suburban
        or products.subway
        or products.tram -- ... some trains seem to be classed as trams?
    )
    -- ... i guess we should whitelist any other extra-territorial stations?
    and (ST_Contains(germany.geom, ST_Point(lon, lat)) or name ilike '%basel%bad%')
    order by name
) to 'db-stations.csv' (header false);
