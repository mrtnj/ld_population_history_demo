#!/bin/bash


## As opposed to GONE, SNeP comes as one binary that can run from any directory. We still creawte
## a working directory to keep the output files in.

mkdir snep

## We loop over all cases, reading the data from the "simulation" directory,
## and directing the output to the "snep" directory. The settings are to
## correct r-squared for sample size using the factor 2, and to use the Haldane
## mapping function. We direct the output to a text file for logging purposes.

for CASE in pop_constant pop_recent pop_ancient pop_migration pop_increase; do

  ./tools/snep/SNeP1.1 \
    -ped simulation/${CASE}.ped \
    -out snep/${CASE} \
    -samplesize 2 \
    -haldane > snep/${CASE}_out.txt
  
done
