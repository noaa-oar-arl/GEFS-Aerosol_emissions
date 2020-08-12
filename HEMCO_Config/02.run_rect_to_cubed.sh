#!/bin/bash

declare -a tiles=(tile1 tile2 tile3 tile4 tile5 tile6)
for tile_num in "${tiles[@]}"; do
echo $tile_num

mkdir -p output/regrid

declare -a dates=(201901010000 201902010000 201903010000 201904010000 201905010000 201906010000 201907010000 201908010000 201909010000 201910010000 201911010000 201912010000)
for date in "${dates[@]}"; do
echo $date

export  srcfile=./output/HEMCO_sa.diagnostics.${date}.nc
export  dstfile=/data/aqf/barryb/fv3grid/fv3grid/C384_grid_spec.${tile_num}.nc
export  wgtfile=/data/aqf/patrickc/fv3_chem_emissions/weights_file_cubed_${tile_num}_FV3.nc
export  infile=./output/HEMCO_sa.diagnostics.${date}.nc
export  outfile=./output/regrid/HEMCO_sa.diagnostics.${date}_${tile_num}.nc

rm -f ${outfile}

ncl rect_to_cubed.ncl

done
done
