-- duckdb
install spatial;
load spatial;

copy (
    select 
    'FR' as country,
    nom as name,
    concat('https://www.garesetconnexions.sncf/fr/gares-services/',
        replace(
            regexp_replace(
                replace(
                    replace(
                        strip_accents(lower(nom)),
                    ' - ', ' '),
                '-', ' '),
            ' en | sur | de | et | le ', ' ')
        , ' ', '-')
    , '/horaires#main-content')
    as url, ST_X(position_geographique) lon, ST_Y(position_geographique) lat from 'gares-de-voyageurs.parquet'
) to 'fr-stations.csv' (header false);
