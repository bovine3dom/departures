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
-- this site is _awful_ so we antijoin with the good rfi one in ../it/it-stations.csv
copy (
    select 'IT_N' as country, titlecase(n.column0) as name,
    concat('https://www.trenord.it/en/routes-and-timetables/journey/real-time/?station=', i.column0, '&stationName=', n.column0) as url,
    lon, lat
    from read_csv('ids.csv',header=false) i
    positional join read_csv('names.csv',header=false) n
    left join (
        -- location data
        -- https://www.dati.lombardia.it/Mobilit-e-trasporti/Flussi-Stazioni-Ferroviarie/m2u2-frtq/about_data
        select distinct codice_aziendale, POINT_X lon, POINT_Y lat from 'Flussi_Stazioni_Ferroviarie_20260424.csv'
    ) f on (i.column0 = f.codice_aziendale)
    anti join read_csv('../it/it-stations.csv',header=false) r on (lower(r.column1) = lower(n.column0))
    where i.column0 is not null
) to 'it_n-stations.csv' (header false);
