#!/bin/julia
using EzXML, CSV, DataFrames
using Statistics: mean
# urls like open https://rtd.banenor.no/web_client/std?layout=portrait&station=OSL
# docs here https://www.banenor.no/apne-data-fa-togtidene-gratis-pa-nett-og-skjermer/
# hmm but that's only the codes and not the names or locations :((
# we have to fight with NetEx again
# https://storage.googleapis.com/marduk-production/tiamat/RailStations_latest.zip
# https://developer.entur.org/stops-and-timetable-data
# jbvCode is what we want
# various centroids
# names
#
# this is so much nicer than db

doc = readxml("_stops.xml")
ns = ["n" => "http://www.netex.org.uk/netex"]

stops = findall("//n:StopPlace", doc.node, ns)

results =[]
# no obvious place for code :((
for sp in stops
    # transport mode = rail
    mode_node = findfirst("./n:TransportMode", sp, ns)
    mode = mode_node !== nothing ? nodecontent(mode_node) : "Unknown"
    mode == "rail" && push!(results, sp)
end
# after all that there's just a nice json endpoint https://rata.digitraffic.fi/api/v1/metadata/stations

#     name_node = findfirst("./n:Name", sp, ns)
#     name = name_node !== nothing ? nodecontent(name_node) : "Unknown"
#     
#     eva_node = findall(".//n:KeyValue/n:Value", sp, ns)
#     nodecontent.(eva_node)
#     eva = eva_node !== nothing ? nodecontent(eva_node) : missing
#     
#     # norway _does_ provide central locations but it's easier to take an average
#     # than use our brains
#     lon_nodes = findall(".//n:Longitude", sp, ns)
#     lat_nodes = findall(".//n:Latitude", sp, ns)
#     local_lat = missing
#     local_lon = missing
# 
#     if !isempty(lon_nodes) && !isempty(lat_nodes)
#         lons = [parse(Float64, nodecontent(n)) for n in lon_nodes]
#         lats = [parse(Float64, nodecontent(n)) for n in lat_nodes]
#         
#         local_lon = mean(lons)
#         local_lat = mean(lats)
#     end
# 
#     push!(results, (
#         name = name,
#         code = ismissing(eva) ? "" : eva,
#         lon = local_lon,
#         lat = local_lat,
#     ))
# end
# 
# df = DataFrame(results)
# df = df[df.code .!= "", :]
# valid_boards = readlines("Stationlist passengers.txt")[3:end]
# valid_boards = first.(split.(valid_boards, " "))
# df = semijoin(df, DataFrame(code=valid_boards), on = :code)
# df.url = "https://rtd.banenor.no/web_client/std?layout=portrait&station=" .* df.code
# 
# df.country .= "NO"
# 
# # [cn]-stations.csv: country, name, url, lon, lat
# CSV.write("no-stations.csv", df[!, [:country, :name, :url, :lon, :lat]], writeheader = false)
