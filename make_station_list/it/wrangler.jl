using CSV, DataFrames, Gumbo, StringDistances, Unicode

h = parsehtml(read("options.html", String))
options = h.root.children[2].children
placeids = Int[]
names = String[]
for o in options
    push!(placeids, parse(Int, o.attributes["value"]))
    push!(names, o.children[1].text)
end
df = DataFrame(placeid = placeids, name = names)

tl = CSV.read("../stations.csv", DataFrame)
tl = tl[(tl.country .== "IT") .&& .!ismissing.(tl.uic) .&& .!ismissing.(tl.latitude) .&& .!ismissing.(tl.longitude), :]
sort!(df, :name)
sort!(tl, :name)

df_names = df.name
tl_names = tl.name

function normalise_name(s)
    s = uppercase(s)
    s = Unicode.normalize(s, stripmark=true)
    s = replace(s, r"\bS\." => "SAN ")
    s = replace(s, r"[^\w\s]" => " ")
    s = replace(s, r"\s+" => " ")
    return strip(s)
end

df_norm = normalise_name.(df_names)
tl_norm = normalise_name.(tl_names)

metric = TokenMax(JaroWinkler())

exact_matches = intersect(df_norm, tl_norm)
df_sad = setdiff(df_norm, exact_matches)
tl_sad = setdiff(tl_norm, exact_matches)

scores = pairwise(metric, df_sad, tl_sad)

results = DataFrame(
    rfi = String[],
    trainline = String[],
    score = Float64[]
)
for (i, source) in enumerate(df_sad)
    best_score, best_idx = findmin(scores[i, :]) # 0.0 is best...
    push!(results, (
        rfi = source,
        trainline = tl_sad[best_idx],
        score = best_score,
    ))
end
print(results)

accepted_matches = DataFrame(
    rfi = String[],
    trainline = String[],
    score = Float64[]
)
skipped_pile = String[]

for (i, source) in enumerate(df_sad)
    best_match_indices = sortperm(scores[i, :])
    item_resolved = false
    for idx in best_match_indices
        target = tl_sad[idx]
        current_score = scores[i, idx]
        println("\nItem $(i)/$(length(df_sad)):")
        printstyled("Source: ", source, "\n", color=:cyan, bold=true)
        printstyled("Match : ", target, " (Distance: $(round(current_score, digits=3)))\n", color=:green, bold=true)
        user_choice = ""
        while true
            print("Action - [y]es / [n]ext best / [s]kip / [q]uit : ")
            user_choice = lowercase(strip(readline()))
            if user_choice in ("y", "n", "s", "q")
                break
            else
                printstyled("Invalid input. Please press y, n, s, or q.\n", color=:red)
            end
        end
        if user_choice == "y"
            push!(accepted_matches, (rfi = source, trainline = target, score = current_score))
            item_resolved = true
            break
        elseif user_choice == "n"
            continue
        elseif user_choice == "s"
            push!(skipped_pile, source)
            item_resolved = true
            break
        elseif user_choice == "q"
            printstyled("\nExiting early! Saving your progress...\n", color=:yellow)
            break
        end
    end
    if !item_resolved
        printstyled("No more matches to show for '$source'. Adding to skipped pile.\n", color=:yellow)
        push!(skipped_pile, source)
    end
end

df.norm = normalise_name.(df.name)
tl.norm = normalise_name.(tl.name)

dfj = leftjoin(df, accepted_matches[!, [:rfi, :trainline]], on = :norm => :rfi)
dfj.joinkey = ifelse.(ismissing.(dfj.trainline), dfj.norm, dfj.trainline)

df_final = leftjoin(dfj, tl[!, [:norm, :latitude, :longitude]], on = :joinkey => :norm)
CSV.write("interim_matches.csv", df_final)

stations2save = DataFrame()
stations2save.url = "https://iechub.rfi.it/ArriviPartenze/ArrivalsDepartures/Monitor?placeId=" .* string.(df_final.placeid) .* "&arrivals=False"
stations2save.name = titlecase.(df_final.name)
stations2save.lat = df_final.latitude
stations2save.lon = df_final.longitude
stations2save.country .= "IT"

CSV.write("it-stations.csv", stations2save[!, [:country, :name, :url, :lon, :lat]], header=false)
