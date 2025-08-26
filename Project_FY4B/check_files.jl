using Ipaper, DataFrames, Dates
using RTableTools

dhour(x::Millisecond) = (x.value / 1000 + 1) / 3600

## 文件存在很多缺失
using RCall
R"""
pacman::p_load(Ipaper, data.table, lubridate)
"""

parse_datetime(x::AbstractString) = DateTime(x, "yyyymmddHHMMSS")
parse_datetime(v::Vector{<:AbstractString}) = parse_datetime.(v)

fs1 = dir("Z:/China/Prcp_Hourly_FY4B_202206-now/RAW1/", r".NC$", recursive=true)
fs2 = dir("Z:/China/Prcp_Hourly_FY4B_202206-now/RAW2/", r".NC$", recursive=true)
fs = vcat(fs1, fs2)
# @time fs = dir(indir, r".NC$")
files = sort(unique(fs))
writelines(files, "filelist.txt")
