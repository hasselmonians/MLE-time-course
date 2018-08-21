# MLE-time-course
Estimate the bandwidth parameter for smoothing spike-train data.

## What is this?
Firing rate is a convenient mathematical construct useful in analyzing spike trains. It's believed that firing rate (measured in number of spikes per unit time) plays an important role in neural coding. Since actual spike-timing is somewhat stochastic, determining the firing rate is often non-trivial. A [2011 paper](https://www.ncbi.nlm.nih.gov/pubmed/21732865) describes a method by which Bayesian likelihood analysis and leave-one-out cross-validation can be used to determine an optimal bandwidth parameter for use in turning point-process spike-train data into smoothed firing rate vs. time curves.

## How do I use it?
The core files are packed within `BandwidthEstimator`.

* `getSpikeTimes`. Produces a vector of spike times from a `CMBHOME` Session object.
* `getSpikeTrain`. Produces a binned spike train vector, where the bin size is determined by the video sample size (for _in-vivo_ recordings).
* `cvKernel`. Perform the leave-one-out cross-validated maximum likelihood analysis. This is the main function in the project.

The project is written in `MATLAB`. You will need to make sure that you have the following dependencies
* `CMBHOME` is required for general access to the `Session` object, though actually, only `fs_video`, `ts` are required. The analysis function will accept most any spike train.
* In the future, this project will be more general, though since the work is predominately already published, this package will not be heavily developed.
