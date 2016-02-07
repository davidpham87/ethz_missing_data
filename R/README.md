# Quickstart

Most functions for imputing are written in the `completion_fns.R` file. Other
useful functions for stating the parameters space for `simsalapar` are stored
in the `simulation_fns.R` file. Some of the functions are unfortunately
dependent on the location working directory (e.g. those loading and saving
data). Hence when using these functions, the working directory of *R* should be
the folder where the two above files are stored.

Simulations are run with the files in the `sim_files` folder. A good idea is to
run them as batch process:

```bash
cd sim_files
R CMD BATCH sim_imputeknn.R
```

The analysis of the simulation outpus are produced with scripts in the
`output_analysis` folder.

The `bug_replication` folder contains scripts to generate low-level errors
using imputations packages (`amelia` and `impute`).


