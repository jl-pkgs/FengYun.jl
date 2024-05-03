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
