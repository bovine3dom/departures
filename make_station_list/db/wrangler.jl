#!/bin/julia
using XML, CSV, DataFrames

stations = read("879076212433727488-2026-04-23T02_25_25.xml", Node)

# i hate xml
stops = children(stations[2][3][1][4][1][3]) .|> children

names = map(s -> value(s[findfirst(x -> tag(x) == "Name", s)][1]), stops)
uses = map(s -> value(s[findfirst(x -> tag(x) == "PublicUse", s)][1]), stops)

# i really hate xml
uics = (s -> begin 
            try
                allkeys = children.(children(s[1])) .|> x-> children.(x) .|> x -> value.(x)[1]
                return parse(Int, (allkeys[findfirst(x -> x[1] == "EVA", allkeys)][2]))
            catch
                return 0
            end
        end).(stops)

# it looks like they have locations but in another file/table, it has 'topographic place ref'. so sod it, let's use trainline


trainline = CSV.read("../stations.csv", DataFrame)

db = DataFrame(name = names, uic = uics)

# why are so many missing :(((
leftjoin!(db, trainline[!, [:uic, :latitude, :longitude]], on = :uic, matchmissing = :notequal)

using HTTP: escapeuri
db.url = "https://bahn.expert/" .* escapeuri.(db.name)
db.country .= "DE"
rename!(db, :latitude => :lat, :longitude => :lon)

# [cn]-stations.csv: country, name, url, lon, lat
CSV.write("db-stations.csv", db[!, [:country, :name, :url, :lon, :lat]], writeheader = false)
