-- duckdb
-- open https://www.cp.pt/en/pesquisa-estacao-detalhe/94-31039
-- looks a lot like uic

-- stations. this is brilliant, it already has lat/lon
-- curl 'https://api-gateway.cp.pt/cp/services/travel-api/stations' \
--   --compressed \
--   -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0' \
--   -H 'Accept: application/json' \
--   -H 'Accept-Language: en-GB,en;q=0.9' \
--   -H 'Accept-Encoding: gzip, deflate, br, zstd' \
--   -H 'Referer: https://www.cp.pt/' \
--   -H 'x-api-key: ca3923e4-1d3c-424f-a3d0-9554cf3ef859' \
--   -H 'x-cp-connect-id: 1483ea620b920be6328dcf89e808937a' \
--   -H 'x-cp-connect-secret: 74bd06d5a2715c64c2f848c5cdb56e6b' \
--   -H 'Origin: https://www.cp.pt' \
--   -H 'Sec-Fetch-Dest: empty' \
--   -H 'Sec-Fetch-Mode: cors' \
--   -H 'Sec-Fetch-Site: same-site' \
--   -H 'Connection: keep-alive' > raw-stations.json

copy (
  select 'PT' country, designation as name, 
  concat('https://www.cp.pt/en/pesquisa-estacao-detalhe/', code) url,
  longitude lon, latitude lat
  from 'raw-stations.json'
) to 'pt-stations.csv' (header false);
