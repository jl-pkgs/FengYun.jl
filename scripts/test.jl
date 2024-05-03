lon, lat = load_FY_latlon("4km")

fig = Figure(; size=(1400, 540))
imagesc!(fig[1, 1], lon, title="lon")
imagesc!(fig[1, 2], lat, title="lat")
fig
