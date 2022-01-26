# tip-filament-tracking
This repository includes two scripts that track 2D and 3D cluster points. The clusters are in the form of 2D contours and 3D strands that move in time and their dynamics can be unpredictable.

The challenging part of the cluster2D program was to find a way for the computer to distinguish two or more clusters. These clusters are curves and strands. By this we mean that their thickness is much smaller than its length. Moreover, and they can take many forms. They also evolve in time, which means we need to apply the algorithm each time step. The result is achieved. We can distinguish one strand from the other, but as time advances, we are unable track (label) the cluster in time. The data that the program can read the output format from the yolohtli repository.

The filament_processing program has the same objective as cluster2D, but now we do it in 3D. 
