-- duckdb
copy (
    select 'GB' country, name, url, 
    longitude lon,
    latitude lat 
    from (
        select d."3ALPHA" a3, concat('https://www.realtimetrains.co.uk/search/simple/gb-nr:', d."3ALPHA") as url, concat('70', d.UIC) as uic from (
            select unnest(TIPLOCDATA) d from read_json('CORPUSExtract.json.gz')
        )
        where d.UIC not like '% %' and d."3ALPHA" not like '% %'
    ) c
    left join '../stations.csv' s on (s.uic = c.uic) or (s.sncf_id = concat('GB', c.a3))
    where latitude is not null and longitude is not null
) to 'gb-stations.csv' (header false);
