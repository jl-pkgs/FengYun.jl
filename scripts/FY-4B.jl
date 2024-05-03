function read_bin(f::String, dim; type=Float32)
  A = Array{type}(undef, dim)
  read!(f, A) # read data, 读取的顺序与python相反
  A
end

# 5496
"""
  read_FY_latlon(f::String, n=2748; type=Float64)
# Arguments
- n: 
  + `4km`: 2748
  + `2km`: 5496
"""
function read_FY_latlon(f::String, n=2748; type=Float64)
  A = read_bin(f, (2, n, n); type)
  A = permutedims(A, 3:-1:1)

  A[A.>9999] .= NaN
  lat = A[:, :, 1]
  lon = A[:, :, 2]
  lon[lon.<0] .+= 360.0
  Float32.(lon), Float32.(lat)
end

function read_band(nc::NCDataset, band="Channel01")
  nom = nc.group["Data"]["NOM$band"]
  ymin, ymax = nom.attrib["valid_range"]
  # missval = nom.attrib["FillValue"]
  
  cal = nc.group["Calibration"]["CAL$band"]
  # cmin, cmax = cal.attrib["valid_range"]

  _nom = Array(nom)
  _cal = Array(cal)

  val = fill(NaN32, size(nom))
  inds = ymin .<= nom[:, :] .<= ymax
  val[inds] .= _cal[_nom[inds]]
  val
end

function load_FY_latlon(res="4km")
  if res == "4km"
    f = "./data/lonlat/FY4B-_DISK_1050E_GEO_NOM_LUT_20240227000000_4000M_V0001.raw"
    n = 2748
  elseif res == "2km"
    f = "./data/lonlat/FY4B-_DISK_1050E_GEO_NOM_LUT_20240227000000_2000M_V0001.raw"
    n = 5496
  end
  read_FY_latlon(f, n) # lon, lat
end
