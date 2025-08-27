include("main_FY_latlon.jl")

using NetCDFTools, Ipaper
using MakieLayers, GLMakie
# using FengYun
# using JLD2
# includet("FY-4B.jl")

begin
    f_loc = "data/FY4B-_DISK_1050E_GEO_NOM_LUT_20240227000000_4000M_V0001.raw"
    lon, lat = read_FY_latlon(f_loc; n=2748) # lon, lat
    n = 2748
    _x = 1:n
    _y = n:-1:1
    ncsave("FY4B-_DISK_1050E_4km.nc"; dims=(; i=_x, j=_y), lon, lat)
end

begin
    f_loc = "data/FY4B-_DISK_1330E_GEO_NOM_LUT_20220323000000_4000M_V0001.raw"
    lon, lat = read_FY_latlon(f_loc; n=2748) # lon, lat
    n = 2748
    _x = 1:n
    _y = n:-1:1
    ncsave("FY4B-_DISK_1330E_4km.nc"; dims=(; i=_x, j=_y), lon, lat)
end

# # f = "data/FY4B-_AGRI--_N_DISK_1050E_L1-_FDI-_MULT_NOM_20240502030000_20240502031459_4000M_V0001.HDF"
# f = "data/FY4B-_AGRI--_N_DISK_1050E_L2-_QPE-_MULT_NOM_20250714014500_20250714015959_4000M_V0001.NC"
# nc = nc_open(f)
# P = nc["Precipitation"][:, :]
# replace!(P, 65535.0 => NaN32)
# replace!(P, 65534.0 => NaN32)
# replace!(P, 65533.0 => NaN32)

begin
    fig = Figure(; size=(1400, 600))
    imagesc!(fig[1, 1], _x, _y, lon; title="lon")
    imagesc!(fig[1, 2], _x, _y, lat; title="lat")
    fig
end
