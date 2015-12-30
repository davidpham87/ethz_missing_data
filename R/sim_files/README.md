# Caution

The *sim* files require the `completion_fns`and `simulation_fns` scripts and
working directory has to be the parent directory. This is taken care inside each
script. However, each of these script must be called directly from the folder. 
E.g. 

```bash
R CMD BATCH sim_mi.R
```

and not from the R folder.

```bash
R CMD BATCH sim_files/sim_mi.R
```
