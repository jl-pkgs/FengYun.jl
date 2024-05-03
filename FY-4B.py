import numpy as np
# import h5py


def fy4disk(rawfile, dim):
    """
    FY-4A数据行列号和经纬度查找表2km、4km，读取raw文件，存成hdf.
    :param rawfile: raw文件全路径
    :param dim: 行列数（2km:5496,4km:2748)
    :return:
    """
    sz = np.fromfile(rawfile, dtype=float, count=dim*dim*2)
    latlon = np.reshape(sz, (dim, dim, 2))

    lat = latlon[:, :, 0]
    lon = latlon[:, :, 1]

    lat[lat > 100] = -9999.
    lon[lon < 0] = lon[lon < 0] + 360.
    lon[lon > 361] = -9999.

    return lon, lat
