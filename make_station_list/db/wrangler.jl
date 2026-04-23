#!/bin/julia
using EzXML, CSV, DataFrames
using Statistics: mean

trainline = CSV.read("../stations.csv", DataFrame)

doc = readxml("879076212433727488-2026-04-23T02_25_25.xml")
ns = ["n" => "http://www.netex.org.uk/netex"]

stops = findall("//n:StopPlace", doc.node, ns)

results =[]
for sp in stops
    name_node = findfirst("./n:Name", sp, ns)
    name = name_node !== nothing ? nodecontent(name_node) : "Unknown"
    
    eva_node = findfirst(".//n:KeyValue[n:Key='EVA']/n:Value", sp, ns)
    eva = eva_node !== nothing ? nodecontent(eva_node) : missing
    
    # this is _INSANE_, db doesn't provide a central location, so go around using like
    # random lifts and staircases and doors and cry about it a lot
    lon_nodes = findall(".//n:Longitude", sp, ns)
    lat_nodes = findall(".//n:Latitude", sp, ns)
    local_lat = missing
    local_lon = missing

    if !isempty(lon_nodes) && !isempty(lat_nodes)
        lons = [parse(Float64, nodecontent(n)) for n in lon_nodes]
        lats = [parse(Float64, nodecontent(n)) for n in lat_nodes]
        
        local_lon = mean(lons)
        local_lat = mean(lats)
    end

    push!(results, (
        name = name,
        uic = ismissing(eva) ? 0 : parse(Int, eva),
        lon = local_lon,
        lat = local_lat,
    ))
end

df = DataFrame(results)

# why are so many missing :(((
db = leftjoin(df, trainline[!, [:uic, :latitude, :longitude]], on = :uic, matchmissing = :notequal, renamecols = :_db => :_tl)
rename!(db, :name_db => :name, :lon_db => :lon, :lat_db => :lat)
db.lon = ifelse.(ismissing.(db.lon), db.longitude_tl, db.lon)
db.lat = ifelse.(ismissing.(db.lat), db.latitude_tl, db.lat)

using HTTP: escapeuri
db.url = "https://bahn.expert/" .* escapeuri.(db.name)
db.country .= "DE"

# [cn]-stations.csv: country, name, url, lon, lat
CSV.write("db-stations.csv", db[!, [:country, :name, :url, :lon, :lat]], writeheader = false)
