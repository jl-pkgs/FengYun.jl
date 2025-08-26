import netCDF4 as nc  # 或 from scipy.io import netcdf 如果是 NetCDF3
import numpy as np

from pyresample import geometry
from pyresample.bilinear import NumpyBilinearResampler
from pyresample._spatial_mp import cKDTree_MP
from pykdtree.kdtree import KDTree
from pyproj import CRS  # 新增导入 CRS
import xarray as xr

wgs84 = CRS.from_epsg(4326)  # EPSG:4326 为 WGS84 经纬度，等价于原字典

def read_data(f):
    with xr.open_dataset(f) as ds:
        X = ds["lon"].values
        Y = ds["lat"].values
        Z = ds["P"].values
        return X, Y, Z


def make_rast(extent=np.array([45, -60, 165, 60]), cellsize=0.05):
    xlims, ylims = extent[[0, 2]], extent[[1, 3]]
    # nx = int((xlims[1] - xlims[0]) / cellsize)
    # ny = int((ylims[1] - ylims[0]) / cellsize)
    lon = np.arange(xlims[0] + cellsize/2, xlims[1], cellsize)
    lat = np.arange(ylims[0] + cellsize/2, ylims[1], cellsize)

    target_def = geometry.AreaDefinition(
        'target_area', 'Regular lon-lat grid', proj_id='longlat',
        projection=wgs84,
        width=len(lon),  height=len(lat),
        area_extent=extent
    )
    return lon, np.flip(lat), target_def



if __name__ == "__main__":
    f = 'FY4B_20250714014500_20250714015959.nc'
    X, Y, Z = read_data(f)
    X, Y, Z

    xx, yy, target_def = make_rast()
    xx, yy, target_def

    source_def = geometry.SwathDefinition(lons=X, lats=Y)
    resampler = NumpyBilinearResampler(source_def, target_def, 4000*4) # radius_of_influence, 4km * 3

    nprocs = 10
    kdtree_class = cKDTree_MP if nprocs > 1  else KDTree
    resampler.get_bil_info(kdtree_class=kdtree_class, nprocs=nprocs)

    # data = np.transpose(Z, (2, 0, 1))  # (ntime, nx, ny)
    Z2 = resampler.get_sample_from_bil_info(Z, fill_value=np.nan, output_shape=None)
    Z2.shape
