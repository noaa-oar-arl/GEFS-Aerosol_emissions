#!/bin/bash

# InterpMethod must be one of bilinear, patch, conserve, nearestdtos, neareststod

export interp_method=conserve
echo $interp_method

declare -a fv3_ress=(C48 C96 C192 C384 C768)
for fv3_res in "${fv3_ress[@]}"; do
echo $fv3_res

declare -a tiles=(tile1 tile2 tile3 tile4 tile5 tile6)
for tile_num in "${tiles[@]}"; do
echo $tile_num

declare -a dates=(201901010000 201902010000 201903040000 201904040000 201905050000 201906050000 201907060000 201908060000 201909060000 201910070000 201911070000 201912080000)
for date in "${dates[@]}"; do
echo $date

export  srcfile=./output/HEMCO_sa.diagnostics.${date}.nc
export  dstfile=/scratch/pcampbe8/UFS/fv3grid/${fv3_res}_grid_spec.${tile_num}.nc
export  wgtfile=/scratch/pcampbe8/UFS/fv3grid/fv3_weights_file_${fv3_res}_${tile_num}_${interp_method}.nc
export  infile=./output/HEMCO_sa.diagnostics.${date}.nc
export  outfile=./output/regrid/HEMCO_sa.diagnostics.${date}_${fv3_res}_${tile_num}.nc

rm -f ${outfile}

ncl rect_to_cubed.ncl

done
done
done
