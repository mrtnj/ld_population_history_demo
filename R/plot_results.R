
## Plot results after running GONE and SNeP on simulated data

library(dplyr)
library(ggplot2)
library(tibble)
library(readr)
library(patchwork)
library(purrr)

source("R/plotting_functions.R")

dir.create("figures")


## Population histories

recent_decrease <- tibble(generations = c(1, 50, 100, 150),
                          Ne = c(1000, 1500, 2000, 3000))

recent_increase <- tibble(generations = c(1, 50, 100, 150),
                          Ne = c(3000, 2000, 1500, 1000))

ancient_decrease <- tibble(generations = c(1, recent_decrease$generations[-1] + 500),
                           Ne = recent_decrease$Ne)


## Plot of true poplation histories

plot_recent <- plot_broken_stick(convert_to_broken_stick(recent_decrease)) + 
  ggtitle("Recent population size decrease")
plot_ancient <- plot_broken_stick(convert_to_broken_stick(ancient_decrease)) +
  ggtitle("Ancient population size decrease")
plot_increase <- plot_broken_stick(convert_to_broken_stick(recent_increase)) +
  ggtitle("Recent population size increase")

plot_combined <- plot_recent / plot_ancient / plot_increase

pdf("figures/true_simulated_histories.pdf",
    height = 10, width = 5)
print(plot_combined)
dev.off()


## Create data frame of true simulated histories with descriptions

cases <- tibble(case = c("pop_constant",
                         "pop_recent",
                         "pop_ancient",
                         "pop_migration",
                         "pop_increase"),
                description = c("Constant",
                                "Recent decrease",
                                "Ancient decrease",
                                "Recent decrease with migration",
                                "Recent increase"))

true <- rbind(transform(convert_to_broken_stick(recent_decrease),
                        case = "pop_recent"),
              transform(convert_to_broken_stick(recent_decrease),
                        case = "pop_migration"),
              transform(convert_to_broken_stick(ancient_decrease),
                        case = "pop_ancient"),
              transform(convert_to_broken_stick(recent_increase),
                        case = "pop_increase"),
              tibble(start = 0, end = 550, Ne = 1000, case = "pop_constant"))

true_descriptions <- inner_join(true, cases)
true_descriptions$description <- factor(true_descriptions$description,
                                        levels = cases$description)





## SnEP results

snep_file_names <- paste("snep/", cases$case, ".NeAll", sep = "")
names(snep_file_names) <- cases$case

snep <- map_dfr(snep_file_names, read_tsv, .id = "case")


snep_descriptions <- inner_join(snep, cases)
snep_descriptions$description <- factor(snep_descriptions$description,
                                        levels = cases$description)

## Make both a plot of the entire range of estimates, and a plot of the
## first 200 generations, which is the region where estimates are expected
## to be of higher quality
plot_snep_unconstrained <- ggplot() +
  geom_point(aes(x = GenAgo, y = Ne),
             data = snep_descriptions,
             colour = "grey") +
  facet_wrap(~ description,
             scale = "free_y",
             ncol = 2) +
  geom_segment(aes(x = start,
                   y = Ne,
                   xend = end,
                   yend = Ne),
               data = true_descriptions) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        strip.background = element_blank()) +
  xlab("Generations ago")

plot_snep <- plot_snep_unconstrained +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 3000))

pdf("figures/snep_results.pdf",
    height = 15, width = 10)
print(plot_snep)
dev.off()

pdf("figures/snep_results_unconstrained.pdf",
    height = 15, width = 10)
print(plot_snep_unconstrained)
dev.off()


## Look at LD decay
  
plot_decay <- qplot(x = dist/1e6, y = r2, colour = description, geom = "line",
                    data = snep_descriptions) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        legend.title = element_blank()) +
  xlab("Distance between markers (Mbp)")




## GONE results

gone_file_names <- paste("gone/Output_Ne_", cases$case, sep = "")
names(gone_file_names) <- cases$case

gone <- map_dfr(gone_file_names, read_tsv, .id = "case", skip = 1)

gone_descriptions <- inner_join(cases, gone)
gone_descriptions$description <- factor(gone_descriptions$description,
                                        levels = cases$description)


plot_gone_unconstrained <- ggplot() +
  geom_point(aes(x = Generation, y = Geometric_mean),
             colour = "grey",
             size = 0.25,
             data = gone_descriptions) +
  facet_wrap(~ description,
             scale = "free_y",
             ncol = 2) +
  geom_segment(aes(x = start,
                   y = Ne,
                   xend = end,
                   yend = Ne),
               data = true_descriptions) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        strip.background = element_blank())

plot_gone <- plot_gone_unconstrained +
  coord_cartesian(xlim = c(0, 200), ylim = c(0, 10000))


pdf("figures/gone_results.pdf",
    height = 15, width = 10)
print(plot_gone)
dev.off()


pdf("figures/gone_results_unconstrained.pdf",
    height = 15, width = 10)
print(plot_gone_unconstrained)
dev.off()