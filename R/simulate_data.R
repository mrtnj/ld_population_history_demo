## Simulate some different population histories for testing

library(AlphaSimR)
library(ggplot2)
library(patchwork)
library(purrr)
library(tibble)


## Population histories

recent_decrease <- tibble(generations = c(1, 50, 100, 150),
                          Ne = c(1000, 1500, 2000, 3000))

recent_increase <- tibble(generations = c(1, 50, 100, 150),
                          Ne = c(3000, 2000, 1500, 1000))

ancient_decrease <- tibble(generations = recent_decrease$generations + 500,
                           Ne = recent_decrease$Ne)


## Construct custom command for model with migration

runMacs2(nInd = 100,
         Ne = recent_decrease$Ne[1],
         histGen = recent_decrease$generations[-1],
         histNe = recent_decrease$Ne[-1],
         split = 100,
         returnCommand = TRUE)

## "1e+08 -t 1e-04 -r 4e-05 -I 2 100 100  -eN 0.0125 1.5 -eN 0.025 2 -eN 0.0375 3 -ej 0.025001 2 1"

## Migration rate 4 * N0 * m (where N0 is the final)
m <- 0.05
print(4 * 1000 * 0.05)

migration_command <- "1e+08 -t 1e-04 -r 4e-05 -I 2 200 0 200  -eN 0.0125 1.5 -eN 0.025 2 -eN 0.0375 3 -ej 0.025001 2 1"


## Run all the simulations

pops <- list(pop_constant = runMacs2(nInd = 100,
                                     nChr = 5,
                                     histNe = NULL,
                                     histGen = NULL,
                                     Ne = 1000),
             
             pop_recent = runMacs2(nInd = 100,
                                   nChr = 5,
                                   Ne = recent_decrease$Ne[1],
                                   histGen = recent_decrease$generations[-1],
                                   histNe = recent_decrease$Ne[-1]),
             
             pop_increase = runMacs2(nInd = 100,
                                     nChr = 5,
                                     Ne = recent_increase$Ne[1],
                                     histGen = recent_increase$generations[-1],
                                     histNe = recent_increase$Ne[-1]),
             
             pop_ancient = runMacs2(nInd = 100,
                                    nChr = 5,
                                    Ne = ancient_decrease$Ne[1],
                                    histGen = ancient_decrease$generations[-1],
                                    histNe = ancient_decrease$Ne[-1]),
             
             pop_migration = runMacs(nInd = 100,
                                     nChr = 5,
                                     manualCommand = migration_command,
                                     manualGenLen = 1))




## Write out data in Plink format

## Function to extract information and turn to Plink ped/map

get_plink_data <- function(pop, max_variants) {

  simparam <- SimParam$new(pop)
  simparam$addSnpChip(nSnpPerChr = max_variants/pop@nChr)
  
  geno <- data.frame(pullSnpGeno(pop, simParam = simparam))
  
  snps <- getSnpMap(simParam = simparam)
  
  map <- tibble(chr = snps$chr,
                name = colnames(geno),
                position_centimorgan = snps$pos * 100,
                position_bp = round(snps$pos * 1e8))
  
  
  ped_metadata <- tibble(fid = 1:pop@nInd,
                         iid = 1:pop@nInd,
                         mother = rep(0, pop@nInd),
                         father = rep(0, pop@nInd),
                         sex = rep(0, pop@nInd),
                         pheno = rep(-9, pop@nInd))
  
  ## Recode to A/C because the allele codes have to be DNA bases
  geno_recoded <- map_dfc(geno, function(g) {
    recoded <- rep("A A", length(g))
    recoded[g == 1] <- "A C"
    recoded[g == 2] <- "C C"
    recoded
  })
  
  n_variants <- ncol(geno)
  if (max_variants < ncol(geno)) {
    to_keep <- sort(sample(1:ncol(geno), max_variants))
    geno_recoded <- geno_recoded[, to_keep]
    map <- map[to_keep,]
  }
  
  ped <- cbind(ped_metadata, geno_recoded)
  
  list(ped = ped,
       map = map)
}

## Function to write Plink bed and maps

write_plink <- function(plink_data, base_name) {
  
  write.table(plink_data$ped,
              file = paste("simulation/", base_name, ".ped", sep = ""),
              quote = FALSE,
              col.names = FALSE,
              row.names = FALSE)
  
  write.table(plink_data$map,
              file = paste("simulation/", base_name, ".map", sep = ""),
              quote = FALSE,
              col.names = FALSE,
              row.names = FALSE)
  
}


## Write out data with 10 000 SNPs 

dir.create("simulation")

pmap(list(pop = pops,
          name = names(pops)),
     function(pop, name) {
       write_plink(get_plink_data(pop, 10000), name)
     })

