# https://github.com/GERSL/Preprocessing-Tools/blob/master/BRDFAdjust.m

# SZA: solar_zenith_angle, 正午为0
# VZA: view_zenith_angle
"""
BRDFADJUST is to use the c-factor approach (Roy, D. P. et al., 2016) based on
the RossThick-LiSparse-R BRDF model (Schaaf, Crystal B., et al. 2002).

# Arguments
- `ref_ori`                 : orginal surface reflectance
- `band_name`               : 'Blue', 'Green', 'Red', 'NIR', 'SWIR1',  'SWIR2'
- `solar_zenith_angle`      : (unit: decimal degrees)
- `view_zenith_angle`       : (unit: decimal degrees)
- `solar_azimuth_angle`     : (unit: decimal degrees)
- `view_azimuth_angle`      : (unit: decimal degrees)
- `centre_lat`              : (unit: decimal degrees)
- `solar_zenith_angle_norm` : (unit: decimal degrees)
"""
function BRDFAdjust(ref_ori, band_name, 
  SZA, VZA, 
  solar_azimuth_angle, view_azimuth_angle, 
  centre_lat=nothing, SZA_norm=nothing)
  
  SZA = deg2rad(SZA)
  VZA = deg2rad(VZA)
  relative_azimuth_angle = deg2rad(view_azimuth_angle - solar_azimuth_angle)

  if centre_lat !== nothing
    SZA_norm_centre = 31.0076 - 0.1272 * centre_lat + 
      0.01187 * centre_lat^2 + 2.4 * 10^(-5) * centre_lat^3 - 9.48 * 10^(-7) * centre_lat^4 - 
      1.95 * 10^(-9) * centre_lat^5 + 6.15 * 10^(-11) * centre_lat^6
    SZA_norm_centre = deg2rad(SZA_norm_centre)
  end

  SZA_norm !== nothing && (SZA_norm_custom = deg2rad(SZA_norm))
  
  if SZA_norm_custom !== nothing
    SZA_norm = SZA_norm_custom
  else
    SZA_norm = SZA_norm_centre !== nothing ? SZA_norm_centre : SZA
  end

  VZA_norm = deg2rad(0)
  relative_azimuth_angle_norm = deg2rad(180)

  band_dict = Dict("Blue" => 1, "Green" => 2, "Red" => 3, "NIR" => 4, "SWIR1" => 5, "SWIR2" => 6)
  lamda = band_dict[band_name]
  
  f_iso = [0.0774, 0.1306, 0.1690, 0.3093, 0.3430, 0.2658]
  f_vol = [0.0372, 0.0580, 0.0574, 0.1535, 0.1154, 0.0639]
  f_geo = [0.0079, 0.0178, 0.0227, 0.0330, 0.0453, 0.0387]

  f_iso = f_iso[lamda]
  f_geo = f_geo[lamda]
  f_vol = f_vol[lamda]

  k_vol_norm, k_geo_norm = kernel(SZA_norm, VZA_norm, relative_azimuth_angle_norm)
  k_vol_sensor, k_geo_sensor = kernel(SZA, VZA, relative_azimuth_angle)

  P1 = f_iso + f_geo * k_geo_norm + f_vol * k_vol_norm
  P2 = f_iso + f_geo * k_geo_sensor + f_vol * k_vol_sensor
  C_lamda = P1 / P2

  round.(Int16, C_lamda * ref_ori) # ref_norm
end


function kernel(θ_s::Real, θ_v::Real, azimuth_angle::Real; b=1, r=1, h=2)
  # Calculate k_vol
  cos_g = cos(θ_s) * cos(θ_v) + sin(θ_s) * sin(θ_v) * cos(azimuth_angle)
  g = acos(clamp(cos_g, -1.0, 1.0))
  k_vol = ((0.5 * π - g) * cos(g) + sin(g)) / (cos(θ_s) + cos(θ_v)) - π / 4

  # Calculate k_geo
  θ_s1 = atan(max(b / r * tan(θ_s), 0))
  θ_v1 = atan(max(b / r * tan(θ_v), 0))

  g_1 = cos(θ_s1) * cos(θ_v1) + sin(θ_s1) * sin(θ_v1) * cos(azimuth_angle)
  g_1 = acos(clamp(g_1, -1, 1))
  D = tan(θ_s1) ^ 2 + tan(θ_v1) .^ 2 - 2 * tan(θ_s1) * tan(θ_v1) * cos(azimuth_angle)
  D = sqrt(max(D, 0))

  cos_t = h / b * (sqrt.(D ^ 2 + (tan(θ_s1) * tan(θ_v1) * sin(azimuth_angle)) ^ 2)) / 
    (sec(θ_s1) + sec(θ_v1))
  cos_t = clamp(cos_t, -1, 1)
  t = acos(cos_t)

  O = 1 / π * (t - sin(t) * cos(t)) * (sec(θ_s1) + sec(θ_v1))
  O = max(O, 0)
  k_geo = O - sec(θ_s1) - sec(θ_v1) + 1 / 2 * (1 + cos(g_1)) * sec(θ_s1) * sec(θ_v1)

  k_vol, k_geo
end

export kernel
export BRDFAdjust
