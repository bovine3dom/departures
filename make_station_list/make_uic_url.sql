-- duckdb
-- todo: work out why french urls get quotes and literally no-one else does
-- might be worth switching to clickhouse-local
load json;
copy (
    select column0 country,
    column1 as name,
    column2 url,
    column3 lon,
    column4 lat,
    column5 uic
    from '*/*-stations.csv' where uic is not null
) to 'uic_departure_url.jsonl';
