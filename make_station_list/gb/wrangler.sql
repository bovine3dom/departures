-- duckdb
CREATE MACRO titlecase(str) AS ( -- why on earth isn't this included
    SELECT list_aggregate( -- bug: words after ( don't get capitalised but who cares
        list_transform(
            regexp_split_to_array(lower(str), '\s+'), 
            lambda x: upper(x[1]) || x[2:]
        ), 
        'string_agg', ' '
    )
);

copy (
    select 'GB' country, ifNull(name, titlecase(network_rail_name)) as name, url,
    longitude lon,
    latitude lat 
    from (
        select d.NLCDESC network_rail_name, d."3ALPHA" a3, concat('https://www.realtimetrains.co.uk/search/simple/gb-nr:', d."3ALPHA") as url, concat('70', d.UIC) as uic from (
            select unnest(TIPLOCDATA) d from read_json('CORPUSExtract.json.gz')
        ) c
        -- get actual stations using ORR data
        -- https://dataportal.orr.gov.uk/statistics/usage/estimates-of-station-usage
        semi join (
select "Three Letter Code
(TLC)" -- lol. it really has a newline. and therefore must have no indentation
a3 from read_csv('table-1410-passenger-entries-and-exits-and-interchanges-by-station.csv', skip=3)
        ) orr on (orr.a3 = c.d."3ALPHA")
    ) c
    left join '../stations.csv' s on (s.uic = c.uic) --or (s.sncf_id = concat('GB', c.a3)) -- this is a trap
    --where latitude is not null and longitude is not null
    order by name
) to 'gb-stations.csv' (header false);
