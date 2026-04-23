# Find the best departure board for a station

I really hate having to remember like a billion different departure board websites when travelling.

After some horrific string matching and hacking around, I've made a dead simple single HTML page with a JS search box that will open the best national departure board for a given station.

# Todo

- make the pipeline less horrific so you don't hate the idea of adding new countries
- add switzerland, austria, germany

# Contributing

yeah let's be honest this repo is horrific so direct contributions are unlikely, _BUT_, if you want to help out, what would be great is, for your pet country:

- what's the best departure board which allows direct linking to a station?
- how do we get from a human friendly name to that link?
- how do we get from that link/human friendly name to a UIC code or lat/lon? (i use this to sort by population because most of the time that's what you want. i will do the join)

i do _not_ suggest trying to open `index.html` in a modern professional 10x engineer ~~text~~ lifestyle editor because it's 10k lines and that makes them sad :((

# Data sources

This project uses data from Network Rail, Trainline, SNCF, Transitous, GHSL, ÖBB and RFI. All data is licenced under ODbL.
