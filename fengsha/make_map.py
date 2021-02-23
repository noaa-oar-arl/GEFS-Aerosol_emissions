#!/usr/bin/env python
import os
import argparse
from numpy import array, arange, isfinite

import xarray as xr

def create_thres(stype,thres):
    from numpy import zeros, shape, arange, where
    ut = zeros(shape(stype))
    for i in arange(1,14):
        ut[where(stype == i)] = thres[int(i)-1]
    return ut

def make_condition(x=arange(1,14),soil=6, soiltype=None):
     soils = x[x != soil]
     con = (soiltype == soils[0]) | (soiltype == soils[1]) | (soiltype == soils[2]) | (soiltype == soils[3]) | (soiltype == soils[4]) | (soiltype == soils[5]) |(soiltype == soils[6]) | (soiltype == soils[7]) |(soiltype == soils[8]) | (soiltype == soils[9]) | (soiltype == soils[10]) | (soiltype == soils[11])
     return con

def patch_threshold(thres_array,con,val=-.5):
    from numpy import where
    thres_array_data = thres_array.data
    thres_array_data[where(con.data.reshape(thres_array_data.shape))] = val
    thres_array.data = thres_array_data
    return thres_array

def patch_threshold_array(thres_array,con,val=0):
    from numpy import where
    thres_array[where(con.data)] = val
    return thres_array

def make_latlon_con(k,latlonbox=[-179.9,0,0,80]):
    from numpy import meshgrid
    lon = k.longitude[0,:]
    if lon.min() < 0:
        lon.data[lon.data <0] = lon.data[lon.data<0] + 360
    lat = k.latitude[:,0]
    latmin = latlonbox[1]
    latmax = latlonbox[3]
    lonmin = latlonbox[0]
    lonmax = latlonbox[2]
    if lonmax < 0:
        lonmax = lonmax + 360
    if lonmin < 0:
        lonmin = lonmin + 360
    if lonmax == 0:
        lonmax = 360.
    latcon = (lat >=latmin) & (lat <= latmax)
    loncon = (lon >= lonmin) & (lon <= lonmax)
    loncons,latcons = meshgrid(loncon,latcon)
    con = loncons & latcons
    return con

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='generate fv3 chem threshold friction velocities',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-f', '--filename',
                        default=None,
                        required=True,
                        help='filename')
    parser.add_argument('-ut', '--threshold_velocity',
                        default="0.34,0.47,0.28,0.35,0.35,0.45,0.50,0.40,0.48,0.45,0.50,0.45,9999.0",
                        required=False,
                        help='Threshold friction Velocity for soil types.  Enter as string: "0.065,0.18,0.28,0.30,0.35,0.45,0.45,0.42,0.42,0.45,0.50,0.45,9999.0"')
    parser.add_argument('-b','--latlon_box',default=None,required=False,help='lat lon box [lonmin, latmin,lonmax,latmax]')
    parser.add_argument('-o','--output',default=None,required=False,help='output filename - if using latlon_box this will be ignored')
    args = parser.parse_args()

    f = xr.open_dataset(args.filename)
    ut = array(args.threshold_velocity.split(','),dtype=float)
    clay = f.clayfrac.where(f.clayfrac <= 1, -1)
    print('     Setting Thresholds...')
    if args.latlon_box is None:
        stype = f.SOIL_TYPE.data
    thres = f.UTHRES.copy()
        thres_data = thres.data.squeeze()
        for index,uthres in enumerate(ut):
            con1 = make_condition(x=arange(1,14),soil=index+1,soiltype=f.SOIL_TYPE)
            thres_data = patch_threshold_array(thres_data,~con1.squeeze(), val=uthres)
        f['UTHRES'].data = thres_data.reshape(thres.shape)
    else:threshold_array(thres.squeeze(),con, val=uthres)
        f['UTHRES'].data = thres.reshape(thresshape)

    f['UTHRES'] = f.UTHRES.where(f.clayfrac >= 0, 10000)

    fname = args.output
    if fname is None:
        fname = args.filename
    if os.path.isfile(fname):
        print('removing ',fname)
        os.remove(fname)
    print('print saving to: ',fname)
    f.to_netcdf(fname)
