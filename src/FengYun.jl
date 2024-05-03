module FengYun

using NCDatasets

export read_bin, read_FY_latlon, load_FY_latlon
export read_band

include("FY_latlon.jl")
include("read_band.jl")
include("BRDF.jl")

end # module FengYun
