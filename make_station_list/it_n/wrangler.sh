# take the <ul> from https://www.trenord.it/en/routes-and-timetables/journey/real-time/?station=S01929&stationName=SEVESO%20BARUCCANA
sed 's|>|>\n|g' raw.html | sed 's|<|\n<|g' | grep -o 'stationDetails(\'[a-zA-Z0-9]*\',\'[a-zA-Z -.]*' | cut -d\' -f2 > ids.csv
sed 's|>|>\n|g' raw.html | sed 's|<|\n<|g' | grep -o 'stationDetails(\'[a-zA-Z0-9]*\',\'[a-zA-Z -.]*' | cut -d\' -f4 > names.csv

