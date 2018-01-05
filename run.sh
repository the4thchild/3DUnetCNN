#!/bin/bash
# Runs the 3DUnetCNN application
# Author: David Young 2018

################################################
# Runs the 3DUnetCNN application including various 
# processing scenarios.
# 
# Arguments:
#   -h: Show help and exit.
#   -b: Convert BRATS data for testing.
#
################################################

convert_brats=0

OPTIND=1
while getopts hb opt; do
    case $opt in
        h)  echo $HELP
            exit 0
            ;;
        b)  convert_brats=1
            echo "Set to convert BRATS data"
            ;;
        :)  echo "Option -$OPTARG requires an argument"
            exit 1
            ;;
        --) ;;
    esac
done

# pass arguments after "--" to clrbrain
shift "$((OPTIND-1))"
EXTRA_ARGS="$@"

# run from script directory
BASE_DIR="`dirname $0`"
cd "$BASE_DIR"
echo $PWD

# setup PATH for the application as well as ANTs
export PYTHONPATH=${PWD}:$PYTHONPATH
export PATH=${PWD}/../build_ants/bin:$PATH
echo $PATH

# convert BRATS data into Nifti format
if [ $convert_brats -eq 1 ]
then
    cd brats
    python -u -m convert_brats.py
fi