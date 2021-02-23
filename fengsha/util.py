#import monetio as mio
import xarray as xr
import numpy as np
#import pandas as pd
import os.path as path

def compute_scale_and_offset(mn, mx, n,dtype=np.float32):
    """
    min is the minumum of the values
    max is the maximum of the values
    n is the integer bit length  (ie 32 for np.int32 or 16 for np.int16)
    """
    # stretch/compress data to the available packed range
    scale_factor = (mx - mn) / (2 ** n - 1)
    # translate the range to be symmetric about zero
    add_offset = mn + 2 ** (n - 1) * scale_factor
    return (scale_factor.astype(dtype), add_offset.astype(dtype))

def pack_value(values, scale_factor, offset, dtype):
    return ((values - offset) / scale_factor).astype(dtype)

def get_min_max(da):
    return (da.min().compute(), da.max().compute())

def check_if_exists(output_name):
    if path.exists(output_name):
        raise ValueError


def write_ncf(dset,output_name, add_scale_factor=True,scale_factor_dtype=np.float32, compress=True,compress_engine='zlib', compression_level=9, positive_definite=False, **kwargs):
    print('Writing:', output_name)
    try:
        check_if_exists(output_name)
    except ValueError:
        print('File Exists! No Action Taken')
        return
    if compress:
        if compress_engine == 'zlib':
            comp = dict(zlib=True,complevel=compression_level)
        elif compress_engine=='gzip':
            comp = dict(compression='gzip',complevel=compression_level)
        encoding = {var: comp for var in dset.data_vars}
#    dset.attrs['date_created'] = pd.to_datetime('today').strftime('%Y-%m-%d')
    if add_scale_factor:
        if isinstance(dset,xr.Dataset):
            for vname in dset.data_vars.keys():
                if (vname != 'TSTEP') | (vname != 'TFLAG') | (vname != 'time'): # do nothing if TSTEP
                    try:
                        if positive_definite:
                            da = dset[vname].where(dset[vname] >= 0)
                        else:
                            da = dset[vname]
                        if da.dtype is np.dtype('float16') or da.dtype is np.dtype('float32') or da.dtype is np.dtype('float64'):
                            mn,mx = get_min_max(da)
                            scale_factor,offset=compute_scale_and_offset(mn,mx,32,dtype=da.dtype)
                            dset[vname].data = pack_value(da,scale_factor,offset,dtype=np.int32).data
                            dset[vname].attrs['scale_factor'] = scale_factor.values
                            dset[vname].attrs['add_offset'] = offset.values
                    except ValueError:
                        print('Something wrong with {}.... No Compression action taken'.format(vname))
        if isinstance(dset,xr.DataArray):
            if positive_definite:
                da = dset.where(dset > 0)
            else:
                da = dset
            if da.dtype is np.dtype('float16') or da.dtype is np.dtype('float32') or da.dtype is np.dtype('float64'):
                try:
                    mn,mx = get_min_max(da)
                    scale_factor,offset=compute_scale_and_offset(mn,mx,16)
                    dset.data = pack_value(da,scale_factor,offset,dtype=np.int16)
                    dset.attrs['scale_factor'] = scale_factor.values
                    dset.attrs['add_offset'] = offset.values
                except ValueError:
                    print('Something wrong with {}.... No Compression action taken'.format(vname))
                dset = dset.to_dataset()
    if compress:
        dset.to_netcdf(output_name,encoding=encoding, **kwargs)
    else:
        dset.to_netcdf(output_name, **kwargs)


# def get_sand_clay(path):
#     tile = path.split('/')[-1].split('tile')[-1]
#     clay = mio.prepchem.open_dataset("{}/clay.dat".format(path),tile=tile)
#     sand = mio.prepchem.open_dataset("{}/sand.dat".format(path),tile=tile)
#     return clay,sand


def calc_soil_type(clay,sand):
    from numpy import zeros,where
    silt = 100 - clay - sand
    stype = zeros(clay.shape)
    stype[where((silt + clay*1.5 < 15.) & (clay < 100))] = 1.  #SAND
    stype[where((silt + 1.5*clay >= 15.) & (silt + 1.5*clay <30) & (clay < 100))] = 2. #Loamy Sand
    stype[where((clay >= 7.) & (clay < 20) & (sand >52) & (silt + 2* clay >=30) & (clay <100))] = 3. #Sandy Loam (cond 1)
    stype[where((clay <   7) & (silt < 50) & (silt+2*clay >= 30) & (clay < 100))]   = 3      # sandy loam (cond 2)
    stype[where((silt >= 50) & (clay >= 12) & (clay < 27 ) & (clay < 100))] = 4      # silt loam (cond 1)
    stype[where((silt >= 50) & (silt < 80) & (clay < 12) & (clay < 100))] = 4      # silt loam (cond 2)
    stype[where((silt >= 80) & (clay < 12) & (clay < 100))]     = 5      # silt
    stype[where((clay >= 7 ) & (clay < 27) &(silt >= 28) & (silt < 50) & (sand <= 52) & (clay < 100))] = 6      # loam
    stype[where((clay >= 20) & (clay < 35) & (silt < 28) & (sand > 45) & (clay < 100))] = 7      # sandy clay loam
    stype[where((clay >= 27) & (clay < 40.) & (sand < 20) & (clay < 100))] =  8      # silt clay loam
    stype[where((clay >= 27) & (clay < 40.) & (sand >= 20) & (sand <= 45) & (clay < 100))] = 9      # clay loam
    stype[where((clay >= 35) & (sand > 45) & (clay < 100))] = 10     # sandy clay
    stype[where((clay >= 40) & (silt >= 40) & (clay < 100))] = 11     # silty clay
    stype[where((clay >= 40) & (sand <= 45) & (silt < 40) & (clay < 100))] = 12     # clay
    stype[where(stype == 0)] = 13
    return stype


# def get_soil_type(path):
#     clay,sand = get_sand_clay(path)
#     st = clay.copy()
#     st.data = calc_soil_type(clay*100,sand*100)
#     return st
