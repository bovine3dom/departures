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

install webbed from community;
load webbed;
-- https://orariotreni.eavsrl.it/teleindicatori/?stazione=1&tipo=P
copy (
    select 
    'IT_C' as country, titlecase(o."#text") as name,
    concat('https://orariotreni.eavsrl.it/teleindicatori/?tipo=P&stazione=', o."value") as url,
    Longitudine lon, Latitudine lat
    from (
        select unnest(option) o from read_html('raw.html')
    )
    left join 'Elenco-Stazioni.csv' on "Codice Unificato" = o."value"
) to 'it_c-stations.csv' (header false);

-- location data from
-- https://www.eavsrl.it/download/elenco-delle-stazioni-ferroviarie-sulle-linee-vesuviane-e-flegree/
-- this is a different set of stations so that's nice
