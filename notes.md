sncf: annoying slugs
rfi: placeid, string match
rtt: uk station codes https://www.realtimetrains.co.uk/search/detailed/gb-nr:SHN


uk station data: https://publicdatafeeds.networkrail.co.uk/ntrod/SupportingFileAuthenticate?type=CORPUS (needs login)

---

it'd be nice if it worked without js but no worries if not

sorting should take same approach as geonames -> string contains (not starts with because e.g. paris gar...) and then sort by pop desc

wget https://github.com/trainline-eu/stations/raw/refs/heads/master/stations.csv

--

schema

[cn]-stations.csv: country, name, url, lon, lat
