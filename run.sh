#!/bin/bash
# Runs the 3DUnetCNN application
# Author: David Young 2018

HELP="
Runs the 3DUnetCNN application including various 
processing scenarios.

Arguments:
    -h: Show help and exit.
    -b: Test on BRATS data.
    -s: Setup Anaconda environment.
    -g: Install Tensorflow GPU package when setting up environment.
        Only used if -s flag also given.
"

setup=0
gpu=0
brats=0
ENV_NAME="unet"
ENV_CONFIG="environment.yml"

OPTIND=1
while getopts hsgb opt; do
    case $opt in
        h)  echo "$HELP"
            exit 0
            ;;
        s)  setup=1
            echo "Set to setup Anaconda environment"
            ;;
        g)  gpu=1
            echo "Set to setup GPU package"
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

if [[ $setup -eq 1 ]]
then
    # setup Anaconda environment
    echo "Checking for $ENV_NAME Anaconda environment..."
    check_env="`conda env list | grep -w $ENV_NAME`"
    if [[ "$check_env" == "" ]]
    then
    	echo "Creating new conda environment..."
    	config="$ENV_CONFIG"
    	if [[ "$gpu" -eq 1 ]]
    	then
    	    # change Tensorflow to GPU package
    	    config="${ENV_CONFIG%.*}_gpu.yml"
    	    sed -e "s/tensorflow/tensorflow-gpu/g" "$ENV_CONFIG" > "$config"
    	fi
    	conda env create -f "$config"
    else
    	echo "$ENV_NAME already exists. Skipping setup."
    fi
    echo "Activating conda environment..."
    source activate "$ENV_NAME"
fi

# setup PATH for the application as well as ANTs
export PYTHONPATH=${PWD}:$PYTHONPATH
export PATH=${PWD}/../build_ants/bin:$PATH
echo $PATH

if [[ $brats -eq 1 ]]
then
    # run test training and prediction
    cd brats
    if [[ ! -e data/preprocessed ]]
    then
        # convert BRATS data into Nifti format
        echo "Converting BRATS data"
        python -u -m convert_brats
    fi
    echo "Training on BRATS data"
    python -u -m train
    python -u -m predict
    python -u -m evaluate
fi
