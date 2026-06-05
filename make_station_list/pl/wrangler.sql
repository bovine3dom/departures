-- duckdb

-- [cn]-stations.csv: country, name, url, lon, lat
copy (
    select country, name,
    'https://old.rozklad-pkp.pl/bin/stboard.exe/en?ld=mobil&protocol=https:&' as url,
    longitude as lon, latitude as lat, uic,
    'POST' as method,
    concat('input=', (db_id::string), '&REQStationS0F=excludeStationAttribute%3BM-&disableEquivs=yes&selectDate=today&boardType=dep&advancedProductMode=&GUIREQProduct_0=on&GUIREQProduct_1=on&GUIREQProduct_2=on&GUIREQProduct_3=on&maxJourneys=10&start=Show') as body
    from '../stations.csv'
    where country = 'PL' and uic is not null and db_id is not null
    and (uic::string)[1:2] == '51'
) to 'pl-stations.csv' (header false);
