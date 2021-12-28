
# Demo of population history inference with linkage disequilibrium

This repo contains simulation code for generating fake data, a couple of bash scripts that demonstrate running GONE and SNeP to infer recent population history from linkage disequilibrium, and an R script to plot the results.


## Programs

Paper about GONE:  Santiago, E., Novo, I., Pardiñas, A. F., Saura, M., Wang, J., & Caballero, A. (2020). Recent demographic history inferred by high-resolution analysis of linkage disequilibrium. Molecular Biology and Evolution, 37(12), 3642-3653. https://doi.org/10.1093/molbev/msaa169

Paper about SNeP: Barbato, M., Orozco-terWengel, P., Tapio, M., & Bruford, M. W. (2015). SNeP: a tool to estimate trends in recent effective population size trajectories using genome-wide SNP data. Frontiers in genetics, 6, 109. https://www.frontiersin.org/articles/10.3389/fgene.2015.00109/full


## Installing the programs

GONE is available at: https://github.com/esrud/GONE

SNeP is available at: https://sourceforge.net/projects/snepnetrends/

I used the Linux binaries for SNeP 1.1 and the version of GONE updated `01/07/2020`.

I created a `tools` directory, used git to clone the GONE repository (thus creating `tools/GONE`) and made a `snep` directory where I put the SNeP1.1 binary.


## Fake data simulation

* `R/simulate_data.R` -- Use the MaCS coalescent simulator within AlphaSimR to generate fake data from a few different population histories, outputting data in Plink ped/map format to the `simulation` directory. 


## Running the programs

* `scripts/run_gone.sh` -- Run GONE on simulated data; creates the `gone` working directory.

* `scripts/run_snep.sh` -- Run SNeP on simulated data; creates the `snep` working directory.


## Plotting the results

* `R/plot_population_history.R` -- Read and plot the results

* `R/plotting_functions.R` -- A couple of helper functions for plotting