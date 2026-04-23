-- duckdb
copy (
    select country, name,
    concat(
        'https://www.rijdendetreinen.nl/en/departures/station/',
        replace(replace(lower(name), ' ', '-'), '’', ''),
        '?style=tb'
    ) as url,
    longitude lon, latitude lat
    from '../stations.csv'
    where country = 'NL'
    and uic is not null
) to 'nl-stations.csv' (header false);
