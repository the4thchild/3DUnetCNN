#!/bin/bash
# Convert BRATS data
# Author: David Young, 2018
"""Simple script to convert BRATS data into Nifti format
according to the 3DUnetCNN testing protocol.
"""

from preprocess import convert_brats_data

convert_brats_data("data/original", "data/preprocessed")