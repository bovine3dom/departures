-- duckdb
install spatial;
load spatial;

copy (
    WITH g AS (
        SELECT 
            nom, 
            ST_X(position_geographique) AS lon, 
            ST_Y(position_geographique) AS lat, 
            codes_uic AS uic 
        FROM 'gares-de-voyageurs.parquet'
    ),
    f AS (
        SELECT 
            nom_gare AS nom, 
            NULL AS lon, 
            NULL AS lat, 
            code_uic_complet AS uic 
        FROM 'frequentation-gares.parquet'
    ),
    stations as (
        SELECT * FROM g
        UNION ALL
        SELECT * 
        FROM f 
        ANTI JOIN g ON f.uic = g.uic
    )
    select 
    'FR' as country,
    nom as name,
    concat('https://www.garesetconnexions.sncf/fr/gares-services/',
        replace(
            regexp_replace(
                regexp_replace(
                    replace(
                        replace(
                            strip_accents(lower(nom)),
                        ' - ', ' '),
                    '-', ' '),
                -- '' is a special escape sequence for '
                '^l''', ''),
            ' en | sur | de | la | et | le | les | l''', ' ', 'gi')
        , ' ', '-')
    , '/horaires#main-content')
    as url, lon, lat from stations
    order by name
) to 'fr-stations.csv' (header false);
