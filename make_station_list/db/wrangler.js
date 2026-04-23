import {readStations} from 'db-stations'
import {stringify} from 'csv-stringify/sync'
import {writeFileSync} from 'fs'

// [cn]-stations.csv: country, name, url, lon, lat
const stations = []
for await (const station of readStations()) {
	stations.push({country: "DE", name: station.name, url: "https://bahn.expert/" + encodeURIComponent(station.name), lon: station.location.longitude, lat: station.location.latitude})
}
writeFileSync("db-stations.csv", stringify(stations))
