using NetCDFTools, SpatRasters
using MakieLayers, GLMakie
using Shapefile
using Shapefile: Table

shp = Table("Z:/Global/GlobalWaterBalance/GlobalWB/data/shp/GlobalLand.shp")
poly_china = Table("D:/Documents/GitHub/nmc_met_graphics/nmc_met_graphics/resources/maps/bou2_4p.shp")
arc_china = Table("D:/Documents/GitHub/nmc_met_graphics/nmc_met_graphics/resources/maps/bou1_4l.shp")

begin
    f = "./FY4B_20250714014500_20250714015959.nc"
    ds = nc_open(f)
    @time Z = ds["P"][:, :]

    n = size(Z)[1]
    _lon = 1:n
    _lat = n:-1:1
    # _lon, _lat = st_dims(f)
end

fout = "./result_v2.nc"
lon, lat = st_dims(fout)
Z2 = nc_read(fout)

colors = [nan_color; resample_colors(amwg256, 12)]
colors = amwg256

begin
    # using CairoMakie, MakieLayers
    fig = Figure(; size=(1400, 600))
    imagesc!(fig[1, 1], _lon, _lat, Z; colors, title="Original")

    kw = (; xlabel="Longitude", ylabel="Latitude", limits=(45, 165, -40, 60))

    ax, plt = imagesc!(fig[1, 2], lon, lat, Z2; title="Resampled", colors, axis=kw)
    lines!(ax, arc_china.geometry, linewidth=0.5, alpha=1, color=:black)
    poly!(ax, poly_china.geometry, color=nan_color, strokewidth=0.2, strokecolor=:black)
    poly!(ax, shp.geometry, color=nan_color, strokewidth=0.5, strokecolor=:black)

    fig
    save("Figure1_FY4B-bilinear-resample.png", fig)
end
# imagesc(lon, reverse(lat), Z)
