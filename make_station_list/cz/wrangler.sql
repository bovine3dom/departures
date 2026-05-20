-- duckdb
-- urls like https://idos.cz/vlakyautobusymhdvse/odjezdy/vysledky/?f=Brno%20hl.n.
copy (
    select country, name,
    concat('https://idos.cz/vlakyautobusymhdvse/odjezdy/vysledky/?f=', name) as url,
    longitude, latitude, if(uic between 5_400_000 and 5_500_000, uic, null) as uic
    -- not perfect, some names are wrong, but i can't immediately find a better source
    from '../stations.csv'
    where country = 'CZ'
) to 'cz-stations.csv' (header false);
