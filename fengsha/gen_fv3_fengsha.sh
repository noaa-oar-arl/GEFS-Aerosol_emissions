#!/bin/bash +x

res='C768'

input_file=../../FENGSHA/FENGSHA_DUST_INPUTS_v0.2.3.nc

###------------------------- SOIL PARAMS

python -W ignore regrid_to_fv3.py -r C768 -i ${input_file} -o clay.dat -v clayfrac -d ./soil/${res}/
python -W ignore regrid_to_fv3.py -r C768 -i ${input_file} -o sand.dat -v sandfrac -d ./soil/${res}/

# uthres
python -W ignore regrid_to_fv3.py -r C768 -i ${input_file} -o uthr.dat -v uthres -d ./soil/${res}/

# drag  - static in time right now
python -W ignore regrid_to_fv3.py -r C768 -i ${input_file} -o rdrag.dat -v drag_part -d ./soil/${res}/

# SSM
python -W ignore regrid_to_fv3.py -r C768 -i ${input_file} -o ssm.dat -v ssm -d ./bsmfv3/${res}/ -m True
