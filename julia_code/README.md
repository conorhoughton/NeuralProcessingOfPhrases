
These programmes generally load the large Fourier coefficient matrices
that have been created by the "step2" matlab programme. They have
paths that will need to be adjusted.

Follwing my usual bad habit these programmes don't save any files,
they print to screen so the output can be sent to file by a > direct.

itpc.jl this is the main programme, it loads the data, organizes it
and works out the ITPC - it also does various bit of stats and output
itpc's for making the graphs.

general.jl has some utilities, including the load functions for
loading the big Fourier coefficient matrices

mean_res.jl calculates the ITPC and some similar quantities we tested

confidence.jl generates fictive data for significance testing peaks
and works out confidence intervals

____________________________

versions of the itpc code hacked for various tests and graphs

itpc_best_electrode.jl looks to see which electrode gives the best ITPC

itpc_boostrap.jl we thought we could use bootstrat to significance
test condition differences in ITPC on a subject by subject basis,
turns out bootstrap gives a poor estimate for these data.

itpc_by_subject.jl switches the roles of trials and participants in working out ITPC and doing stats.

itpc_get_electrode_phase.jl prints out mean phases for one electrode

power.jl prints out powers for making an example power graphs

