function read_bin(f::String, dim; type=Float32)
  A = Array{type}(undef, dim)
  read!(f, A) # read data, 读取的顺序与python相反
  A
end

"""
  read_FY_latlon(f::String, n=2748; type=Float64)
# Arguments
- n: 
  + `4km`: 2748
  + `2km`: 5496
"""
function read_FY_latlon(f::String; type=Float64, n=2748)
  A = read_bin(f, (2, n, n); type)
  # A = permutedims(A, 3:-1:1)
  # A = permutedims(A, (3, 1, 2))
  A[A.>9999] .= NaN
  lat = A[1, :, :]
  lon = A[2, :, :]
  lon[lon.<0] .+= 360.0
  Float32.(lon), Float32.(lat)
end


# function load_FY_latlon(res="4km")
#   indir = "$(@__DIR__)/../data/lonlat/"
  
#   if res == "4km"
#     f = "$indir/FY4B-_DISK_1050E_GEO_NOM_LUT_20240227000000_4000M_V0001.raw"
#     n = 2748
#   elseif res == "2km"
#     f = "$indir/FY4B-_DISK_1050E_GEO_NOM_LUT_20240227000000_2000M_V0001.raw"
#     n = 5496
#   end
#   read_FY_latlon(f; n) # lon, lat
# end
