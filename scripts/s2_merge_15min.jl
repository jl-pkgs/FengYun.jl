using NetCDFTools, Ipaper, RTableTools
using DataFrames, Dates
import NaNStatistics

include("main_FY_latlon.jl")

function read_data(f)
    # unit: mm; 因此用的是nansum
    # 65535:Outer Space, 65534:Fill Value, 65533:Satellitezenith Angle greater than 90
    P = nc_read(f, "Precipitation")
    replace!(P, 65535.0 => NaN32)
    replace!(P, 65534.0 => NaN32)
    replace!(P, 65533.0 => NaN32)
    P
end

function process_15min(d::SubDataFrame)
    outdir = "Z:/China/Prcp_Hourly_FY4B_202206-now/FY4B_15min_processed_1hour"

    prefix = str_extract(basename(f), r".*(?=_NOM_\d{8})")

    date_beg = DateTime(d.date[1], "yyyy-mm-ddTHH:MM:SSZ")
    date_end = date_beg + Hour(1) - Second(1)

    str_beg = format(date_beg, "yyyymmddHHMMSS")
    str_end = format(date_end, "yyyymmddHHMMSS")
    fout = "$outdir/$(prefix)_NOM_$(str_beg)_$(str_end)_4000M_V0001.nc"

    isfile(fout) && return

    A = map(read_data, d.file) |> x -> cat(x..., dims=3)
    _A = NaNStatistics.nansum(A, dims=3)[:, :, 1]
    ncsave(fout, true, (; units="mm"); dims=(; i=_x, j=_y), P=_A)
end


df = fread("./selected_FY4B_15min_2022-2024.csv")
lst = groupby(df, [:date])

for i in 1:length(lst)
    mod(i, 10) == 0 && println("running $i")
    
    d = lst[i]
    process_15min(d)
end

# imagesc(_x, _y, P)
