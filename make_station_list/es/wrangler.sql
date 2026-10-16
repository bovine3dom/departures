-- duckdb
-- Input: datagrabber's adif_station_catalogue output and Trainline's stations.csv.
copy (
    with trainline as (
        select * from read_csv('../stations.csv', all_varchar = true)
        where country = 'ES' and regexp_full_match(uic, '71[0-9]{5}')
    ), adif as (
        select *, longitude between -19 and 5 and latitude between 27 and 44 as located
        from read_json('adif-stations.json')
    )
    select 'ES', coalesce(a.name, t.name),
        coalesce(a.url, concat('https://pantallas-estaciones.vercel.app/~/?station=',
            substr(t.uic, 3), '&showAllTrains=true')),
        coalesce(if(a.located, a.longitude, null), try_cast(t.longitude as double)),
        coalesce(if(a.located, a.latitude, null), try_cast(t.latitude as double)),
        coalesce(t.uic, a.uic) as uic
    from adif a
    full outer join trainline t on t.uic = concat('71', a.station)
    where coalesce(t.uic, a.uic) is not null
    order by try_cast(t.id as bigint) nulls last, a.station
) to 'es-stations.csv' (header false);
