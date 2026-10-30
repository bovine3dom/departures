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
    latitude lat,
    c.uic
    from (
        select d.NLCDESC network_rail_name, d."3ALPHA" a3, concat('https://www.realtimetrains.co.uk/search/simple/gb-nr:', d."3ALPHA") as url, if(d.UIC != ' ', concat('70', d.UIC), null) as uic from (
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

CREATE MACRO titlecase(str) AS ( -- why on earth isn't this included
    SELECT list_aggregate( -- bug: words after ( don't get capitalised but who cares
        list_transform(
            regexp_split_to_array(lower(str), '\s+'), 
            lambda x: upper(x[1]) || x[2:]
        ), 
        'string_agg', ' '
    )
);

select 'GB' country, titlecase(network_rail_name) as name, url,
c.uic
from (
    select d.NLCDESC network_rail_name, d."3ALPHA" a3, concat('https://www.realtimetrains.co.uk/search/simple/gb-nr:', d."3ALPHA") as url, if(d.UIC != ' ', concat('70', d.UIC), null) as uic from (
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
anti join '../stations.csv' s on (s.uic = c.uic) --or (s.sncf_id = concat('GB', c.a3)) -- this is a trap
--where latitude is not null and longitude is not null
order by name;

copy (
    with stations as (
        select row_number() over () as station_order, *
        from read_csv('stations.csv', delim=';', header=true, all_varchar=true)
    ), corpus as (
        select a3, min(uic) as uic
        from (
            select d."3ALPHA" a3, concat('70', d.UIC) as uic
            from (
                select unnest(TIPLOCDATA) d from read_json('CORPUSExtract.json.gz')
            ) c
            where d.UIC != ' '
        )
        group by a3
        having count(distinct uic) = 1
    ), updates as (
        select
            a3,
            uic,
            concat(
                uic,
                ((10 - (
                    (
                        if(d1 * 2 > 9, d1 * 2 - 9, d1 * 2) +
                        d2 +
                        if(d3 * 2 > 9, d3 * 2 - 9, d3 * 2) +
                        d4 +
                        if(d5 * 2 > 9, d5 * 2 - 9, d5 * 2)
                    ) % 10
                )) % 10)::varchar
            ) as uic8_sncf
        from (
            select
                a3,
                uic,
                substring(right(uic, 5), 1, 1)::int as d1,
                substring(right(uic, 5), 2, 1)::int as d2,
                substring(right(uic, 5), 3, 1)::int as d3,
                substring(right(uic, 5), 4, 1)::int as d4,
                substring(right(uic, 5), 5, 1)::int as d5
            from corpus
        )
    )
    select s.* exclude (station_order) replace (
        coalesce(u.uic, s.uic) as uic,
        coalesce(u.uic8_sncf, s.uic8_sncf) as uic8_sncf
    )
    from stations s
    left join updates u on s.country = 'GB' and s.uic is null and s.atoc_id = u.a3
    order by s.station_order
) to 'trainline-gift.csv' (header true, delimiter ';');
