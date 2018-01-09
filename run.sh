#!/bin/bash
# Runs the 3DUnetCNN application
# Author: David Young 2018

HELP="
Runs the 3DUnetCNN application including various 
processing scenarios.

Arguments:
  -h: Show help and exit.
  -b: Test on BRATS data.
"

brats=0

OPTIND=1
while getopts hb opt; do
    case $opt in
        h)  echo "$HELP"
            exit 0
            ;;
        b)  brats=1
            echo "Set to run BRATS test data"
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
if [[ $brats -eq 1 ]]
then
    cd brats
    if [[ ! -e data/preprocessed ]]
    then
        echo "Converting BRATS data"
        python -u -m convert_brats
    fi
    echo "Training on BRATS data"
    python -u -m train
fi
