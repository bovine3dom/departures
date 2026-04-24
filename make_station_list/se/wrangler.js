import {writeFileSync} from 'fs';
import {stringify} from 'csv-stringify/sync';
const resp = await fetch("https://api.trafikinfo.trafikverket.se/v2/data.json", {
    "credentials": "omit",
    "headers": {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:148.0) Gecko/20100101 Firefox/148.0",
        "Accept": "*/*",
        "Accept-Language": "en-GB,en;q=0.9",
        "Content-Type": "text/plain",
        "Sec-Fetch-Dest": "empty",
        "Sec-Fetch-Mode": "cors",
        "Sec-Fetch-Site": "same-site",
        "Priority": "u=4"
    },
    "referrer": "https://www.trafikverket.se/",
    "body": "<REQUEST>\n        <LOGIN authenticationkey='707695ca4c704c93a80ebf62cf9af7b5'/> \n        <QUERY  objecttype='TrainStation' schemaversion='1.4'>\n          <INCLUDE>Geometry</INCLUDE>\n      <INCLUDE>AdvertisedLocationName</INCLUDE>\n      <INCLUDE>LocationSignature</INCLUDE>\n      <INCLUDE>Prognosticated</INCLUDE>\n      <INCLUDE>CountryCode</INCLUDE>\n    \n            <FILTER>\n                <OR><AND><EQ name=\"Prognosticated\" value=\"true\" /> <EQ name=\"CountryCode\" value=\"SE\" /></AND><NOTIN name = \"CountryCode\" value = \"SE\" /></OR>\n            </FILTER>\n          \n        </QUERY>\n    </REQUEST>",
    "method": "POST",
    "mode": "cors"
});

const json = await resp.json();

const stations = json["RESPONSE"]["RESULT"][0]["TrainStation"].map(station => {
    const wgs84 = station["Geometry"]["WGS84"];
    const [lon, lat] = wgs84.substring(wgs84.indexOf("(") + 1, wgs84.indexOf(")")).split(" ");
    const name = station["AdvertisedLocationName"];
    return {
        country: station["CountryCode"],
        name,
        url: "https://www.trafikverket.se/trafikinformation/tag/?Station=" + name.replace(/ /g, "+") + "&ArrDep=departure#stheader",
        lon,
        lat,
    }
});
writeFileSync('se-stations.csv', stringify(stations.filter(x=>x.country === 'SE')));
