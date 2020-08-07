#!/bin/bash

month=${1}
res=${2}

#------------------------Set these here -------------
#res='C384'
#res='C96'
#base_dir=emi_C96
base_dir=bsmfv3
directory=${base_dir}/${res}/${month}
#----------------------------------------------------
#for month in 01 02 03 04 05 06 07 08 09 10 11 12; do
#for month in 03; do

echo "SETTING DEFAULT THRESHOLDS"
#        1    2    3    4    5    6    7    8    9    10   11   12
#thres="0.34,0.47,0.42,0.35,0.35,0.40,0.43,0.40,0.43,0.45,0.50,0.45,9999.0"
thres="0.34,0.40,0.42,0.35,0.35,0.40,0.39,0.40,0.58,0.50,0.50,0.45,9999.0"
./make_map.py -ut $thres -d $directory -r $res

    # # # Modify Bodele 
    # # echo " MODIFYING AFRICA ----------------------------------------"
    #          1    2    3    4    5    6    7    8    9    10   11   12
    # # thres="0.11,0.25,0.28,0.30,0.35,0.38,0.55,0.41,0.50,0.45,0.50,0.45,9999.0"
    # # box="14.5,13.4,18.3,16.1"
    
    # # ./modify_latlon_box.py -ut $thres -d $directory -b $box -r $res
    
    # # # MODIFY AUS
    # echo " MODIFYING AUS -------------------------------------------"
    # thres="0.12,0.25,0.35,0.30,0.31,0.38,0.55,0.45,0.50,0.45,0.50,0.45,9999.0"

    # box="108,-40,154,-11"

    # ./modify_latlon_box.py -ut $thres -d $directory -b $box -r $res
#modify n africa
#        1    2    3    4    5    6    7    8    9    10   11   12
thres="0.34,0.40,0.43,0.35,0.35,0.40,0.42,0.40,0.58,0.50,0.50,0.45,9999.0"
box="-20,3.3,35,36"
./modify_latlon_box.py -ut ${thres} -d ${directory} -r $res --latlon_box=$box --barren=False

echo " MODIFYING MALI 1 --------------------------------------"
#        1    2    3    4    5    6    7    8    9    10   11   12
thres="0.34,0.40,0.45,0.35,0.35,0.44,0.44,0.40,0.58,0.50,0.50,0.45,9999.0"
box="-16,13.5,19.4,22"
./modify_latlon_box.py -ut ${thres} -d ${directory} -r $res --latlon_box=$box --barren=False

echo " MODIFYING MALI 2 --------------------------------------"
#        1    2    3    4    5    6    7    8    9    10   11   12
thres="0.34,0.40,0.47,0.35,0.35,0.44,0.47,0.40,0.60,0.50,0.50,0.45,9999.0"
box="-5.4,15.4,0.2,23"
./modify_latlon_box.py -ut ${thres} -d ${directory} -r $res --latlon_box=$box --barren=False

# echo " MODIFYING Algeria --------------------------------------"
# #        1    2    3    4    5    6    7    8    9    10   11   12
# thres="0.34,0.40,0.43,0.35,0.35,0.42,0.44,0.40,0.50,0.50,0.50,0.45,9999.0"
# box="29.3,-1.6,30.4,0.5"
# ./modify_latlon_box.py -ut ${thres} -d ${directory} -b $box -r $re

# MODIFY TAKLAMAKAN and Gobi
echo " MODIFYING TALKAMAKAN and GOBI --------------------------------------"
#        1    2    3    4    5    6    7    8    9    10   11   12
thres="0.34,0.40,0.45,0.35,0.35,0.40,0.45,0.39,0.40,0.45,0.50,0.45,9999.0"
box="75.6,36,122,41.1"

./modify_latlon_box.py -ut ${thres} -d ${directory} -b $box -r $res --barren=True

    # # Modify Middle East
    # echo " MODIFYING Middle East ----------------------------------------"
    # thres="0.12,0.31,0.32,0.35,0.35,0.42,0.45,0.45,0.50,0.45,0.50,0.45,9999.0"
    # box="36,5.,75,45"

    # ./modify_latlon_box.py -ut $thres -d $directory -b $box -r $res --barren=True

    # # # modify horn of Africa
    # #  echo " modify horn of Africa ----------------------------------------"
    # #  thres="0.125,0.35,0.35,0.35,0.35,0.40,0.45,0.41,0.50,0.45,0.50,0.45,9999.0"
    # #  box="35,4,55,12"
    # #  ./modify_latlon_box.py -ut $thres -d $directory -b $box -r $res
    
    # # MODIFY CENTRAL US
    # echo " MODIFYING CENTRAL US -------------------------------------------"
    # thres="0.12,0.30,0.28,0.50,0.45,0.38,0.40,0.50,0.50,0.27,0.50,0.45,9999.0"
    # box="-126,25,-65,50"
    
    # ./modify_latlon_box.py -ut $thres -d $directory -r $res --latlon_box=$box

    # # Modify Nothern Mexico for continuity
    # echo " MODIFYING MX for Continuity -------------------------------------------"
    # thres="0.12,0.30,0.28,0.50,0.45,0.38,0.45,0.50,0.50,0.27,0.50,0.45,9999.0"
    # box="-117.95,18,-94.6,36"

    # ./modify_latlon_box.py -ut $thres -d $directory -r $res --latlon_box=$box


    # # PATCH BEDROCK
    # echo " NO emissin over bedrock -------------------------------------------"

    # ./mask_bedrock.py -d $directory
#echo "scale uth with ssm to account for extreme drag partition"
./scale_uth_with_ssm.py -d $directory -s 10

#Done
