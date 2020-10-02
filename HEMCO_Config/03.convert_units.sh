#!/bin/bash

#HEMCO units to FV3-Chem/PREP-CHEM-SRCs
#Aerosols (kg/m2/s to ug/m2/s) = 1e9
#Gases, SO2 Example (kg/m2/s to moles/km2/hr) = 5.62e10

rm output/regrid/*convert*.nc

declare -a times=(20190101 20190201 20190304 20190404 20190505 20190605 20190706 20190806 20190906 20191007 20191107 20191208)

declare -a tiles=(tile1 tile2 tile3 tile4 tile5 tile6)

for time_num in "${times[@]}"; do
echo $time_num
for tile_num in "${tiles[@]}"; do
echo $tile_num

ncap2 -s    SO2=SO2*5.62e10 output/regrid/HEMCO_sa.diagnostics.${time_num}0000_${tile_num}.nc  output/regrid/HEMCO_sa.diagnostics.${time_num}0000_${tile_num}_convert.nc
ncap2 -A -s OC=OC*1e9  output/regrid/HEMCO_sa.diagnostics.${time_num}0000_${tile_num}.nc  output/regrid/HEMCO_sa.diagnostics.${time_num}0000_${tile_num}_convert.nc
ncap2 -A -s BC=BC*1e9  output/regrid/HEMCO_sa.diagnostics.${time_num}0000_${tile_num}.nc  output/regrid/HEMCO_sa.diagnostics.${time_num}0000_${tile_num}_convert.nc
ncap2 -A -s PM25=PM25*1e9  output/regrid/HEMCO_sa.diagnostics.${time_num}0000_${tile_num}.nc  output/regrid/HEMCO_sa.diagnostics.${time_num}0000_${tile_num}_convert.nc

done
done
