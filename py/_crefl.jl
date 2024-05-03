using LinearAlgebra

function G_calc(zenith, a_coeff)
  (cosd(zenith) + (a_coeff[1] * (zenith^a_coeff[2]) * (a_coeff[3] - zenith)^a_coeff[4]))^-1
end
