#!/bin/bash

## Gone needs all the content of the operating system-specific subfolder to be copied
## into a working directory to run from. Therefore we create the "gone" directory
## and copy in the Linux version of the software from the tools directory.

mkdir gone

cd gone

cp -r ../tools/GONE/Linux/* .

## Loop over all the cases and invoke the GONE runscript. Again, because GONE
## needs the data to be in the same directory, we copy the data files into the
## working directory.

for CASE in pop_constant pop_recent pop_ancient pop_migration pop_increase; do

  cp ../simulation/${CASE}.* .
  
  ./script_GONE.sh ${CASE}
  
done
