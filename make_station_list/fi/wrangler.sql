-- duckdb
-- urls like https://junalahdot.fi/turku#content
-- copy (
--     select country, name,
--     concat('https://junalahdot.fi/', 
--         replace(name, ' asema', ''),
--     '?lang=3#content') as url,
--     longitude lon, latitude lat from '../stations.csv' where country = 'FI'
-- ) to 'fi-stations.csv' (header false);

-- :( :( lots of these names aren't the official ones
-- nope. we need the three letter codes because otherwise turku satama / asema can't be accessed
-- i guess let's try NetEx again
-- https://mobility.mobility-database.fintraffic.fi/static/finland_netex.zip (big)

-- json yey https://junalahdot.fi/turku?command=main&action=sbd'
-- lol they don't like curl. why would u want to fetch json from curl. really json is for humans to read.
-- 
-- curl 'https://junalahdot.fi/turku?command=main&action=sbd' \
--   -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0' \
--   -H 'Accept: application/json, text/javascript, */*; q=0.01' \
--   -H 'Accept-Language: en-GB,en;q=0.9' \
--   -H 'Accept-Encoding: gzip, deflate, br, zstd' \
--   -H 'X-Requested-With: XMLHttpRequest' \
--   -H 'Connection: keep-alive' \
--   -H 'Referer: https://junalahdot.fi/turku' \
--   -H 'Sec-Fetch-Dest: empty' \
--   -H 'Sec-Fetch-Mode: cors' \
--   -H 'Sec-Fetch-Site: same-origin' \
--   -H 'TE: trailers' > raw-stations-ids.json

-- curl 'https://rata.digitraffic.fi/api/v1/metadata/stations' \
--   --compressed \
--   -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0' \
--   -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
--   -H 'Accept-Language: en-GB,en;q=0.9' \
--   -H 'Accept-Encoding: gzip, deflate, br, zstd' \
--   -H 'Alt-Used: rata.digitraffic.fi' \
--   -H 'Connection: keep-alive' \
--   -H 'Upgrade-Insecure-Requests: 1' \
--   -H 'Sec-Fetch-Dest: document' \
--   -H 'Sec-Fetch-Mode: navigate' \
--   -H 'Sec-Fetch-Site: same-origin' \
--   -H 'Sec-Fetch-User: ?1' \
--   -H 'Priority: u=0, i' > raw-stations.json



--- eugghghghg enfin
copy (
    select countryCode country, stationName as name,
    concat('https://junalahdot.fi/', stationShortCode, '?command=fs&lang=3&id=', id, '#content') as url,
    longitude lon, latitude lat
    from 'raw-stations-ids.json' ids
    left join 'raw-stations.json' locs on lower(stationShortCode) = lower(code)
    where countryCode = 'FI'
    and ids.type = 'station'
) to 'fi-stations.csv' (header false);
